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

# Backup queue url
queue = sqs.get_queue_url(QueueName=os.environ["BACKUP_QUEUE"])["QueueUrl"]

# Dynamodb client
dynamodb = session.create_client("dynamodb")

# Backup table
table = os.environ["BACKUP_TABLE"]


# Entry point
def lambda_handler(event, context):

    # Load message from json
    message = json.loads(event["Records"][0]["body"])

    # Remote dynamodb client
    remote_dynamodb = session.create_client("dynamodb", region_name=message["table-region"])

    # Remote s3 client
    remote_s3 = session.create_client("s3", region_name=message["bucket-region"])

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


    # Scan source table, up to 1 MB of items
    response = remote_dynamodb.scan(
        TableName=message["table-name"],
        ExclusiveStartKey=message["exclusive-start-key"],
        Segment=message["segment"],
        TotalSegments=message["total-segments"]
    ) if "exclusive-start-key" in message else remote_dynamodb.scan(
        TableName=message["table-name"],
        Segment=message["segment"],
        TotalSegments=message["total-segments"]
    )

    # Dump items into utf-8 encoded json
    data = json.dumps(response["Items"], ensure_ascii=False).encode("utf-8")

    # Compress data using zlib
    body = zlib.compress(data)

    # Build s3 key
    key = "/".join([message["bucket-prefix"], hex(message["segment"]), hex(message["batch"])])

    # Write batch to s3
    remote_s3.put_object(
        Bucket=message["bucket-name"],
        Key=key,
        Body=body
    )

    # Increment batch number
    message["batch"] += 1

    # Increment item count
    message["count"] += response["Count"]


    # Check for more work
    if "LastEvaluatedKey" in response:

        # Update exclusive start key
        message["exclusive-start-key"] = response["LastEvaluatedKey"]

        # Send updated message back to work
        sqs.send_message(QueueUrl=queue, MessageBody=message)

    # Segment complete
    else:

        # Increment complete segments, batches, & items
        dynamodb.update_item(
            TableName=table,
            Key={"key": {"S": message["key"]}, "timestamp": {"N": message["timestamp"]}},
            ExpressionAttributeNames={
                "#S": "complete-segments",
                "#B": "complete-batches",
                "#I": "complete-items"
            },
            ExpressionAttributeValues={
                ":S": {"N": "1"},
                ":B": {"N": str(message["batch"])},
                ":I": {"N": str(message["count"])}
            },
            UpdateExpression="SET #S = #S + :S, #B = #B + :B, #I = #I + :I"
        )

        # Print status message
        print(f'{message["key"]} {message["timestamp"]} segment {message["segment"]} complete')
