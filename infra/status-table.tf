resource "aws_dynamodb_table" "status_table" {
  name         = "${var.project}-${var.release}-status-table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "table-arn"
  range_key = "timestamp"

  attribute {
    name = "table-arn"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  # attribute {
  #     name = "s3-arn"
  #     type = "S"
  # }
}
