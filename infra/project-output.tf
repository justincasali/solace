output "request_queue_id" {
  value = "${aws_sqs_queue.request_queue.id}"
}

output "backup_table_id" {
  value = "${aws_dynamodb_table.backup_table.id}"
}

output "restore_table_id" {
  value = "${aws_dynamodb_table.restore_table.id}"
}
