data "archive_file" "restore_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src/restore-lambda"
  output_path = "${path.root}/../archive/restore-lambda.zip"
}

resource "aws_lambda_function" "restore_lambda" {
  function_name = "${local.prefix}-restore-lambda"
  role          = "${aws_iam_role.restore_lambda_role.arn}"
  tags          = "${var.tags}"

  depends_on = [
    "aws_sqs_queue.restore_queue",
    "aws_dynamodb_table.restore_table",
  ]

  filename         = "${data.archive_file.restore_lambda_zip.output_path}"
  source_code_hash = "${data.archive_file.restore_lambda_zip.output_base64sha256}"

  runtime = "python3.7"
  handler = "restore-lambda.lambda_handler"
  timeout = "${var.restore_timeout}"

  environment {
    variables {
      RESTORE_QUEUE = "${aws_sqs_queue.restore_queue.id}"
      RESTORE_TABLE = "${aws_dynamodb_table.restore_table.id}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "restore_lambda_trigger" {
  event_source_arn = "${aws_sqs_queue.restore_queue.arn}"
  function_name    = "${aws_lambda_function.restore_lambda.function_name}"
  batch_size       = 1
}
