import botocore.session
import json
import zlib
import os

# Stage constants
TRANSFER, END = "transfer", "end"

# AWS session
session = botocore.session.get_session()

# Sqs client
sqs = session.create_client("sqs")

# Restore queue url
queue = sqs.get_queue_url(QueueName=os.environ["RESTORE_QUEUE"])["QueueUrl"]

# Dynamodb client
dynamodb = session.create_client("dynamodb")

# Restore table
table = os.environ["RESTORE_TABLE"]


# Entry point
def lambda_handler(event, context):

    # Load message from json
    message = json.loads(event["Records"][0]["body"])

    # Remote s3 client
    remote_s3 = session.create_client("s3", region_name=message["bucket-region"])

    # Remote dynamodb client
    remote_dynamodb = session.create_client("dynamodb", region_name=message["table-region"])

    # Init stage
    if "exclusive-start-key" not in message:

        # Setup vars
        message["batch"], message["count"] = 0, 0

        # Update stage to run
        dynamodb.update_item(
            TableName=table,
            Key={"key": {"S": message["key"]}, "timestamp": {"N": message["timestamp"]}},
            ExpressionAttributeNames={"#S": "stage"},
            ExpressionAttributeValues={":R": {"S": TRANSFER}},
            UpdateExpression="SET #S = :R"
        )
