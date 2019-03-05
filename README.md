# Solace
serverless cross-region dynamodb to s3 backup restore tool

### preface

this program does what you tell it to do and just that, it's a nitty gritty backend.

backing up to an existing bucket-prefix will result in conflated backup data.

restoring onto a table with existing data will result in conflated table entries.

bad inputs will do bad things, send requests programmatically or wrap tool with a user friendly api.

## use

### request message

send a message to the `request-queue` with the following format:

```
message = {
    "action":           backup or restore,
    "total-segments":   integer less than or equal to maximum_segments,
    "table-region":     dynamodb region string,
    "table-name":       dynamodb table name,
    "bucket-region":    s3 region string,
    "bucket-name":      s3 bucket name,
    "bucket-prefix":    s3 object prefix,
}
```

## status
check a backup's status with the `backup-table` and a restore's status with the `restore-table`.

* task is done: `completed-segments + failed-segments == total-segments`
* task has succeeded: `completed-segments == total-segments`
* task has failed: `failed-segments > 0`

## setup

### config

configuration vars can be found in the `infra/project-vars.tf`.

create `tfvars` files within the `config/` directory to configure the infrastructure and backend.

### deploy

```
terraform init -backend-config 'config/<backend-file>.tfvars' infra/
terraform apply -var-file 'config/<var-file>.tfvars' infra/
```

## infra
### sqs
### lambda
### dynamodb
### iam

## data schema

```
bucket/prefix/segment/batch
```

batch is zlib compressed json dump of dynamodb entries.
segment and batch are `0x` prefixed hex values.

## monitoring
- in normal operation it's permitted for the `backup-lambda` and `restore-lambdas` to fail without much concern.
- `redrive-lambda` invocations represent the rate that backup/restore batches are being rerouted after failing.
- `request-lambda` errors represent the rate of bad requests.


## limitations
- currently no way to kill a backup/restore task once it starts.
- lambda default concurrent execution limit of 1000.
- backup is not point in time but _range_ in time.
