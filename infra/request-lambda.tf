data "archive_file" "request_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/request-lambda"
  output_path = "${path.module}/../archive/request-lambda.zip"
}
