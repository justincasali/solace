data "archive_file" "request_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src/request-lambda"
  output_path = "${path.root}/../archive/request-lambda.zip"
}

resource "aws_lambda_function" "request_lambda" {
  function_name = "${local.project}-${var.env}-request-lambda"
  role          = "${aws_iam_role.request_lambda_role.arn}"

  depends_on = [
    "aws_sqs_queue.request_queue",
    "aws_sqs_queue.backup_queue",
    "aws_sqs_queue.restore_queue",
    "aws_dynamodb_table.backup_table",
    "aws_dynamodb_table.restore_table",
  ]

  filename         = "${data.archive_file.request_lambda_zip.output_path}"
  source_code_hash = "${data.archive_file.request_lambda_zip.output_base64sha256}"

  runtime = "python3.7"
  handler = "request-lambda.lambda_handler"
  timeout = "${var.request_timeout}"

  environment {
    variables {
      REQUEST_QUEUE = "${aws_sqs_queue.request_queue.id}"
      BACKUP_QUEUE  = "${aws_sqs_queue.backup_queue.id}"
      RESTORE_QUEUE = "${aws_sqs_queue.restore_queue.id}"
      BACKUP_TABLE  = "${aws_dynamodb_table.backup_table.id}"
      RESTORE_TABLE = "${aws_dynamodb_table.restore_table.id}"
      MAX_SEGMENTS  = "${var.max_segments}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "request_lambda_trigger" {
  event_source_arn = "${aws_sqs_queue.request_queue.arn}"
  function_name    = "${aws_lambda_function.request_lambda.function_name}"
  batch_size       = 1
}
