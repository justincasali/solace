# solace 🏝
Serverless cross-region DynamoDB S3 backup restore tool.

### Preface

This program does what you tell it to do and just that, it's a nitty gritty backup/restore engine.

Backing up to an existing bucket-prefix will result in conflated backup data.

Restoring onto a table with existing data will result in conflated table entries.

Bad inputs will do bad things, send requests programmatically or wrap tool with user friendly interface.

## Use

### Request Message

Send a message to the `request-queue` with the following format:

```
{
    "action":           backup or restore,
    "total-segments":   integer less than or equal to maximum_segments,
    "table-region":     dynamodb region string,
    "table-name":       dynamodb table name,
    "bucket-region":    s3 region string,
    "bucket-name":      s3 bucket name,
    "bucket-prefix":    s3 object prefix,
}
```

### action

Action for the tool to preform, `backup` or `restore`.

### total-segments

Segments backup data is split into. Each segment runs independently allowing a task to run in parallel.

With backups this value is chosen by the operator. 1 segment per TB of data is recommended.

With restores this value must match the `total-segments` the data was backuped with.

### table-region & table-name

DynamoDB region and table name. With `backup` this is the source and with `restore` this is the destination.

### bucket-region & bucket-name

S3 region and bucket name. With `backup` this is the destination and with `restore` this is the source.

### bucket-prefix

Location of data within S3, stored under the prefix path. Be sure to change this every backup to avoid conflating data. Try using a two part prefix like `table-name/timestamp/`.


## Status

Check a task's status with the `backup-table` and `restore-table`:

* Task is done: `completed-segments + failed-segments == total-segments`
* Task has succeeded: `completed-segments == total-segments`
* Task has failed: `failed-segments > 0`

## Setup

### Config

Configuration vars can be found in the `infra/project-vars.tf`.

Create `.tfvars` files within the `config/` directory to configure the infra and backend settings.

### Deploy

```
terraform init -backend-config 'config/<backend-file>.tfvars' infra/
terraform apply -var-file 'config/<var-file>.tfvars' infra/
```

## Infra (working on diagram)

### SQS + Lambda

Each sqs queue has an associated lambda function set up to trigger on message receive.

`request-queue` + `request-lambda`: This function processes incoming messages, initializes the task entry in the database, and seeds the respective processing queue with a message per segment

`backup-queue` + `restore-lambda`: This function backups up data one batch at a time, sending an updated message to the queue if more data exists.

`restore-queue` + `restore-lambda`: This function restores data one batch at a time, sending an updated message to the queue if more data exists.

`redrive-queue` + `redrive-lambda`: This function collects failed backup/restore messages and increments the failed-segments field in the database.


### DynamoDB

Status and record tables for backup and restore tasks.

### IAM

Backup/Restore roles currently have blanket access to DynamoDB & S3 and must be refined.

## Data Schema

```
bucket/prefix/segment/batch
```

Batch is `zlib` compressed `pickle` serialization of DynamoDB entries.

Segments and batches are `0x` prefixed hex values.

## Monitoring
- In normal operation it's permitted for the `backup-lambda` and `restore-lambdas` to fail without concern.
- `redrive-lambda` invocations represent the rate that backup/restore batches are being rerouted after failing.
- `request-lambda` errors represent the rate of bad requests.


## Limitations
- Currently no way to kill a backup/restore task once it starts.
- Lambda default concurrent execution limit of 1000 per backup/restore task.
- Backup is not point in time but _range_ in time, fits with DynamoDB's eventually consistent nature.
- Backup entries are serialized for storage using the python pickle library and thus are language specific.
