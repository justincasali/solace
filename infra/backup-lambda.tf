data "archive_file" "backup_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src/backup-lambda"
  output_path = "${path.root}/../archive/backup-lambda.zip"
}

resource "aws_lambda_function" "backup_lambda" {
  function_name = "${var.project}-${var.release}-backup-lambda"
  role          = "${aws_iam_role.backup_lambda_role.arn}"

  depends_on = [
    "aws_sqs_queue.backup_queue",
    "aws_dynamodb_table.backup_table",
  ]

  filename         = "${data.archive_file.backup_lambda_zip.output_path}"
  source_code_hash = "${data.archive_file.backup_lambda_zip.output_base64sha256}"

  runtime = "python3.7"
  handler = "backup-lambda.lambda_handler"
  timeout = "${var.backup_task["timeout"]}"

  environment {
    variables {
      BACKUP_QUEUE      = "${aws_sqs_queue.backup_queue.id}"
      BACKUP_TABLE      = "${aws_dynamodb_table.backup_table.id}"
      COMPRESSION_LEVEL = "${var.compression_level}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "backup_lambda_trigger" {
  event_source_arn = "${aws_sqs_queue.backup_queue.arn}"
  function_name    = "${aws_lambda_function.backup_lambda.function_name}"
  batch_size       = 1
}
