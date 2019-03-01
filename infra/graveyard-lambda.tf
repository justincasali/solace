data "archive_file" "graveyard_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/graveyard-lambda"
  output_path = "${path.module}/../artifact/graveyard-lambda.zip"
}

resource "aws_lambda_function" "graveyard_lambda" {
  function_name = "${var.project}-${var.release}-graveyard-lambda"
  role          = "${aws_iam_role.graveyard_lambda_role.arn}"

  depends_on = [
    "aws_sqs_queue.request_queue",
    "aws_sqs_queue.backup_queue",
    "aws_sqs_queue.restore_queue",
    "aws_sqs_queue.graveyard_queue",
    "aws_dynamodb_table.backup_table",
    "aws_dynamodb_table.restore_table",
  ]

  filename         = "${data.archive_file.graveyard_lambda_zip.output_path}"
  source_code_hash = "${data.archive_file.graveyard_lambda_zip.output_base64sha256}"

  runtime = "python3.7"
  handler = "graveyard-lambda.lambda_handler"
  timeout = "${var.graveyard_timeout}"

  environment {
    variables {
      BACKUP_TABLE    = "${aws_dynamodb_table.backup_table.name}"
      RESTORE_TABLE   = "${aws_dynamodb_table.restore_table.name}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "graveyard_lambda_trigger" {
  event_source_arn = "${aws_sqs_queue.graveyard_queue.arn}"
  function_name    = "${aws_lambda_function.graveyard_lambda.function_name}"
  batch_size       = 1
}
