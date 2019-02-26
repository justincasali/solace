data "archive_file" "backup_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/backup-lambda"
  output_path = "${path.module}/../archive/backup-lambda.zip"
}
