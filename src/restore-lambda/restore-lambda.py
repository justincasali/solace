import botocore.session
import json
import pickle
import zlib
import os

# AWS session
session = botocore.session.get_session()

# Sqs client
sqs = session.create_client("sqs")

# Restore queue
queue = os.environ["RESTORE_QUEUE"]

# Dynamodb client
dynamodb = session.create_client("dynamodb")

# Restore table
table = os.environ["RESTORE_TABLE"]

# Max dynamo write batch size
BATCH_SIZE = 25


# Entry point
def lambda_handler(event, context):

    # Load message from json
    message = json.loads(event["Records"][0]["body"])

    # Remote s3 client
    remote_s3 = session.create_client("s3", region_name=message["bucket-region"])

    # Remote dynamodb client
    remote_dynamodb = session.create_client("dynamodb", region_name=message["table-region"])

    # Init
    if "continuation-token" not in message:

        # Setup vars
        message["batch"], message["count"] = 0, 0

    # Build segment specific prefix
    prefix = "/".join([message["bucket-prefix"], hex(message["segment"]), ""])

    # Get key under prefix (one per run)
    list_response = remote_s3.list_objects_v2(
        Bucket=message["bucket-name"],
        Prefix=prefix,
        ContinuationToken=message["continuation-token"],
        MaxKeys=1,
    ) if "continuation-token" in message else remote_s3.list_objects_v2(
        Bucket=message["bucket-name"],
        Prefix=prefix,
        MaxKeys=1
    )

    # Read object from s3
    get_response = remote_s3.get_object(
        Bucket=message["bucket-name"],
        Key=list_response["Contents"][0]["Key"]
    )

    # Unpack body
    body = get_response["Body"].read()

    # Close stream
    get_response["Body"].close()

    # Decompress data
    data = zlib.decompress(body)

    # Deserialize items
    items = pickle.loads(data)

    # Get item count
    count = len(items)

    # Calculate number of batch loops (int ceil)
    loops, extra = divmod(count, BATCH_SIZE)
    if extra != 0: loops += 1

    # Loop through items in small batches
    for batch in range(loops):

        # Item subset
        subset = items[BATCH_SIZE*batch:BATCH_SIZE*(batch+1)]

        # Batch write to dynamo table
        write_response = remote_dynamodb.batch_write_item(
            RequestItems={
                message["table-name"]: [{"PutRequest": {"Item": item}} for item in subset]
            }
        )

        # Throw error if items were not written
        if write_response["UnprocessedItems"] != {}:
            raise Exception("unprocessed items in batch write")

    # Increment batch number
    message["batch"] += 1

    # Increment item count
    message["count"] += count


    # Check for more work
    if "NextContinuationToken" in list_response:

        # Update exclusive start key
        message["continuation-token"] = list_response["NextContinuationToken"]

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
