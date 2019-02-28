import botocore.session
import json
import os

# Stage constants
REQUEST, QUEUE = "request", "queue"

# AWS session
session = botocore.session.get_session()

# Sqs client
sqs = session.create_client("sqs")

# Backup queue url
backup_queue = sqs.get_queue_url(QueueName=os.environ["BACKUP_QUEUE"])["QueueUrl"]

# Restore queue url
restore_queue = sqs.get_queue_url(QueueName=os.environ["RESTORE_QUEUE"])["QueueUrl"]

# Dynamodb client
dynamodb = session.create_client("dynamodb")

# Backup table
backup_table = os.environ["BACKUP_TABLE"]

# Restore Table
restore_table = os.environ["RESTORE_TABLE"]


# Entry point
def lambda_handler(event, context):

    # Load message from json
    message = json.loads(event["Records"][0]["body"])

    # Add timestamp to message
    message["timestamp"] = event["Records"][0]["attributes"]["SentTimestamp"]

    # Ensure prefix ends with "/"
    if message["bucket-prefix"][-1] != "/":
        message["bucket-prefix"] += "/"

    # Backup vars
    if message["action"] == "backup":

        # Set table and queue and build key
        table, queue = backup_table, backup_queue
        message["key"] = "-".join([message["table-region"], message["table-name"]])

    # Restore vars
    if message["action"] == "restore":

        # Set table and queue and build key
        table, queue = restore_table, restore_queue
        message["key"] = "-".join([message["bucket-region"], message["bucket-name"], message["bucket-prefix"]])

    # Error on invalid action
    if message["action"] != "backup" and message["action"] != "restore":
        raise Exception("invalid request action")


    # Write entry to db
    dynamodb.put_item(TableName=table, Item={
        "key":               {"S": message["key"]},
        "timestamp":         {"N": message["timestamp"]},
        "table-region":      {"S": message["table-region"]},
        "table-name":        {"S": message["table-name"]},
        "bucket-region":     {"S": message["bucket-region"]},
        "bucket-name":       {"S": message["bucket-name"]},
        "bucket-prefix":     {"S": message["bucket-prefix"]},
        "total-segments":    {"N": str(message["total-segments"])},
        "complete-segments": {"N": "0"},
        "complete-batches":  {"N": "0"},
        "complete-items":    {"N": "0"},
        # "complete":          {"BOOL": False},
        # "failure":           {"BOOL": False},
        "stage":             {"S": REQUEST}
    })

    # Seed queue
    for segment in range(message["total-segments"]):

        # Set message segment
        message["segment"] = segment

        # Send message to queue
        sqs.send_message(QueueUrl=queue, MessageBody=json.dumps(message))

    # Update stage to queue
    dynamodb.update_item(
        TableName=table,
        Key={"key": {"S": message["key"]}, "timestamp": {"N": message["timestamp"]}},
        ExpressionAttributeNames={"#S": "stage"},
        ExpressionAttributeValues={":Q": {"S": QUEUE}},
        UpdateExpression="SET #S = :Q"
    )


    # Print status message
    print(f'sent {message["key"]} {message["timestamp"]} to {message["action"]} queue')
