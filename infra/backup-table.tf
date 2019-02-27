resource "aws_dynamodb_table" "backup_table" {
  name         = "${var.project}-${var.release}-backup-table"
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
