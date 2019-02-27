data "archive_file" "restore_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/restore-lambda"
  output_path = "${path.module}/../artifact/restore-lambda.zip"
}

resource "aws_lambda_function" "restore_lambda" {
  function_name = "${var.project}-${var.release}-restore-lambda"
  role          = "${aws_iam_role.restore_lambda_role.arn}"

  filename         = "${data.archive_file.restore_lambda_zip.output_path}"
  source_code_hash = "${data.archive_file.restore_lambda_zip.output_base64sha256}"

  runtime = "python3.7"
  handler = "restore-lambda.lambda_handler"
  timeout = "${var.restore_timeout}"

  environment {
    variables {
      RESTORE_QUEUE = "${aws_sqs_queue.restore_queue.name}"
      RESTORE_TABLE = "${aws_dynamodb_table.restore_table.name}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "restore_lambda_trigger" {
  event_source_arn = "${aws_sqs_queue.restore_queue.arn}"
  function_name    = "${aws_lambda_function.restore_lambda.function_name}"
  batch_size       = 1
}
