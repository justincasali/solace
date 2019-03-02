import botocore.session
import json
import os

# AWS session
session = botocore.session.get_session()

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

    # Backup vars
    if message["action"] == "backup":

        # Set table
        table = backup_table

    # Restore vars
    if message["action"] == "restore":

        # Set table
        table = restore_table


    # Increment failed segments
    dynamodb.update_item(
        TableName=table,
        Key={"key": {"S": message["key"]}, "timestamp": {"N": message["timestamp"]}},
        ExpressionAttributeNames={"#S": "failed-segments"},
        ExpressionAttributeValues={":S": {"N": "1"}},
        UpdateExpression="SET #S = #S + :S"
    )


    # Print status message
    print(f'{message["key"]} {message["timestamp"]} segment {message["segment"]} failed')
