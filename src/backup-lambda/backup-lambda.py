import botocore.session
import json
import zlib
import os

# AWS session
session = botocore.session.get_session()

# Sqs client
sqs = session.create_client("sqs")

# Backup queue
queue = os.environ["BACKUP_QUEUE"]

# Dynamodb client
dynamodb = session.create_client("dynamodb")

# Backup table
table = os.environ["BACKUP_TABLE"]

# Zlib compression level
compression_level = int(os.environ["COMPRESSION_LEVEL"])


# Entry point
def lambda_handler(event, context):

    # Load message from json
    message = json.loads(event["Records"][0]["body"])

    # Remote dynamodb client
    remote_dynamodb = session.create_client("dynamodb", region_name=message["table-region"])

    # Remote s3 client
    remote_s3 = session.create_client("s3", region_name=message["bucket-region"])

    # Init
    if "exclusive-start-key" not in message:

        # Setup vars
        message["batch"], message["count"] = 0, 0

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
    body = zlib.compress(data, level=compression_level)

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
        sqs.send_message(QueueUrl=queue, MessageBody=json.dumps(message))

    # Segment complete
    else:

        # Increment completed segments, batches, & items
        dynamodb.update_item(
            TableName=table,
            Key={"key": {"S": message["key"]}, "timestamp": {"N": message["timestamp"]}},
            ExpressionAttributeNames={
                "#S": "completed-segments",
                "#B": "transferred-batches",
                "#I": "transferred-items"
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
