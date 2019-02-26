data "archive_file" "request_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/request-lambda"
  output_path = "${path.module}/../archive/request-lambda.zip"
}

resource "aws_lambda_function" "request_lambda" {
  function_name = "${var.project}-${var.release}-request-lambda"
  role          = "${aws_iam_role.request_lambda_role.arn}"

  filename         = "${data.archive_file.request_lambda_zip.output_path}"
  source_code_hash = "${data.archive_file.request_lambda_zip.output_base64sha256}"

  runtime = "python3.7"
  handler = "request-lambda.lambda_handler"
  timeout = "${var.request_timeout}"

  environment {
    variables {
      STATUS_TABLE = "${aws_dynamodb_table.status_table.name}"
      REQUEST_QUEUE = "${aws_sqs_queue.request_queue.name}"
      BACKUP_QUEUE = "${aws_sqs_queue.backup_queue.name}"
      RESTORE_QUEUE = "${aws_sqs_queue.restore_queue.name}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "request_lambda_trigger" {
  event_source_arn = "${aws_sqs_queue.request_queue.arn}"
  function_name    = "${aws_lambda_function.request_lambda.function_name}"
  batch_size       = 1
}
