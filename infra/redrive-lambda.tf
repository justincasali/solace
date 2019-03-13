data "archive_file" "redrive_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src/redrive-lambda"
  output_path = "${path.root}/../archive/redrive-lambda.zip"
}

resource "aws_lambda_function" "redrive_lambda" {
  function_name = "${local.prefix}-redrive-lambda"
  role          = "${aws_iam_role.redrive_lambda_role.arn}"
  tags          = "${var.tags}"

  depends_on = [
    "aws_sqs_queue.redrive_queue",
    "aws_dynamodb_table.backup_table",
    "aws_dynamodb_table.restore_table",
  ]

  filename         = "${data.archive_file.redrive_lambda_zip.output_path}"
  source_code_hash = "${data.archive_file.redrive_lambda_zip.output_base64sha256}"

  runtime = "python3.7"
  handler = "redrive-lambda.lambda_handler"
  timeout = "${var.redrive_timeout}"

  environment {
    variables {
      REDRIVE_QUEUE = "${aws_sqs_queue.redrive_queue.id}"
      BACKUP_TABLE  = "${aws_dynamodb_table.backup_table.id}"
      RESTORE_TABLE = "${aws_dynamodb_table.restore_table.id}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "redrive_lambda_trigger" {
  event_source_arn = "${aws_sqs_queue.redrive_queue.arn}"
  function_name    = "${aws_lambda_function.redrive_lambda.function_name}"
  batch_size       = 1
}
