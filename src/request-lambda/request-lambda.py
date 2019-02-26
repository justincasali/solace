import botocore.session
import json
import os

# Status constants
RECEIVED, QUEUED = "received", "queued"

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

# Status table
status_table = os.environ["STATUS_TABLE"]


# Entry point
def lambda_handler(event, context):

    # Get timestamp
    timestamp = event["Records"][0]["attributes"]["SentTimestamp"]

    # Load message from json
    message = json.loads(event["Records"][0]["body"])

    # Write entry to db
    dynamodb.put_item(TableName=status_table, Item={
        "table-arn": {"S": message["table-arn"]},
        "timestamp": {"N": timestamp},
        "s3-arn":    {"S": message["s3-arn"]},
        "action":    {"S": message["action"]},
        "status":    {"S": RECEIVED}
    })

    # Backup action
    if message["action"] == "backup":

        # Send message
        sqs.send_message(QueueUrl=backup_queue, MessageBody=json.dumps(message))

        # Update entry
        dynamodb.update_item(
            TableName=status_table,
            Key={"table-arn": {"S": message["table-arn"]}, "timestamp": {"N": message["timestamp"]}},
            ExpressionAttributeNames={"#N": "status"},
            ExpressionAttributeValues={":V": {"S": QUEUED}},
            UpdateExpression="SET #N = :V"
        )

        # Complete
        return

    # Restore action
    if message["action"] == "restore":

        # Send message
        sqs.send_message(QueueUrl=restore_queue, MessageBody=json.dumps(message))

        # Update entry
        dynamodb.update_item(
            TableName=status_table,
            Key={"table-arn": {"S": message["table-arn"]}, "timestamp": {"N": message["timestamp"]}},
            ExpressionAttributeNames={"#N": "status"},
            ExpressionAttributeValues={":V": {"S": QUEUED}},
            UpdateExpression="SET #N = :V"
        )

        # Complete
        return

    # Error on invalid action
    raise Exception("invalid request action")
