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

    # Try to updated entry to failure (database entry may not exist)
    try:

        # Load message from json
        message = json.loads(event["Records"][0]["body"])

        # Ensure prefix ends with "/"
        if message["bucket-prefix"][-1] != "/":
            message["bucket-prefix"] += "/"

        # Backup vars
        if message["action"] == "backup":

            # Set table and build key
            table = backup_table
            message["key"] = "-".join([message["table-region"], message["table-name"]])

        # Restore vars
        if message["action"] == "restore":

            # Set table and build key
            table = restore_table
            message["key"] = "-".join([message["bucket-region"], message["bucket-name"], message["bucket-prefix"]])

        # Update entry to failure
        dynamodb.update_item(
            TableName=table,
            Key={"key": {"S": message["key"]}, "timestamp": {"N": message["timestamp"]}},
            ExpressionAttributeNames={"#F": "failure"},
            ExpressionAttributeValues={":T": {"BOOL": True}},
            UpdateExpression="SET #F = :T"
        )

    # On error
    except:

        # Print status message
        print(f'message found in graveyard without valid key: {event["Records"][0]["body"]}')

    # On success
    else:

        # Print status message
        print(f'{message["key"]} {message["timestamp"]} found in graveyard: {event["Records"][0]["body"]}')
