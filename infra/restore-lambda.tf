data "archive_file" "restore_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/restore-lambda"
  output_path = "${path.module}/../archive/restore-lambda.zip"
}
