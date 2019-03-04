# solace
serverless cross-region dynamodb to s3 backup restore tool

## use
this program does what you tell it to do and just that, it's a nitty gritty backend 

backuping up to an existing bucket-prefix will result in conflated backup data

restoring onto table with existing data will result in conflated table entries

send message to `request-queue` with the following format

```
message = {
    "action":           backup or restore,
    "total-segments":   integer less than or equal to maximum segments,
    "table-region":     dynamodb region string,
    "table-name":       dynamodb table name,
    "bucket-region":    s3 region string,
    "bucket-name":      s3 bucket name,
    "bucket-prefix":    s3 object prefix,
}
```

check backup status with the `backup-table`

check restore status with the `restore-table`

## setup
### config
### deploy

## infra
### sqs
### lambda
### dynamodb
### iam

## data schema
```
bucket/prefix/segment/batch
```
batch is zlib compressed json of dynamodb entries

## monitoring
- in normal operation it's permitted for the backup/restore lambdas to fail
- watch `redrive_queue` invocations, this reflects backup/restore segment failures
- watch `request_queue` errors, this reflects bad requests

## limitations
- currently no way to kill a backup/restore task once it starts
- lambda default concurrent execution limit of 1000
- backup is not point in time but _range_ in time

## future features
- cross-account functionality
