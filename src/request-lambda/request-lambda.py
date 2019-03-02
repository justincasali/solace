import botocore.session
import json
import os

# Stage constants
REQUEST, QUEUE = "request", "queue"

# AWS session
session = botocore.session.get_session()

# Sqs client
sqs = session.create_client("sqs")

# Request queue
request_queue = os.environ["REQUEST_QUEUE"]

# Backup queue
backup_queue = os.environ["BACKUP_QUEUE"]

# Restore queue
restore_queue = os.environ["RESTORE_QUEUE"]

# Dynamodb client
dynamodb = session.create_client("dynamodb")

# Backup table
backup_table = os.environ["BACKUP_TABLE"]

# Restore table
restore_table = os.environ["RESTORE_TABLE"]

# Max segments
max_segments = int(os.environ["MAX_SEGMENTS"])


# Entry point
def lambda_handler(event, context):

    # Delete message from queue (will not requeue on error)
    sqs.delete_message(
        QueueUrl=request_queue,
        ReceiptHandle=event["Records"][0]["receiptHandle"]
    )

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
        raise Exception(f'invalid request action "{message["action"]}"')

    # Reject task with too many segments
    if int(message["total-segments"]) > max_segments:
        raise Exception(f'too many segments, {message["total-segments"]} > {str(max_segments)}')


    # Write entry to db
    dynamodb.put_item(TableName=table, Item={
        "key":                 {"S": message["key"]},
        "timestamp":           {"N": message["timestamp"]},
        "table-region":        {"S": message["table-region"]},
        "table-name":          {"S": message["table-name"]},
        "bucket-region":       {"S": message["bucket-region"]},
        "bucket-name":         {"S": message["bucket-name"]},
        "bucket-prefix":       {"S": message["bucket-prefix"]},
        "total-segments":      {"N": str(message["total-segments"])},
        "completed-segments":  {"N": "0"},
        "failed-segments":     {"N": "0"},
        "transferred-batches": {"N": "0"},
        "transferred-items":   {"N": "0"},
        "stage":               {"S": REQUEST}
    })

    # Attempt to send messages to queue
    try:
        # Seed queue
        for segment in range(message["total-segments"]):

            # Set message segment
            message["segment"] = segment

            # Send message to queue
            sqs.send_message(QueueUrl=queue, MessageBody=json.dumps(message))

    # On failure rollback
    except:

        # Remove entry from db
        dynamodb.delete_item(
            TableName=table,
            Key={"key": {"S": message["key"]}, "timestamp": {"N": message["timestamp"]}}
        )

        # Throw caught error
        raise

    # On success continue
    else:

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
