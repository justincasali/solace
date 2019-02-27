resource "aws_dynamodb_table" "restore_table" {
  name         = "${var.project}-${var.release}-restore-record"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "key"
  range_key = "timestamp"

  attribute {
    name = "key"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }
}
