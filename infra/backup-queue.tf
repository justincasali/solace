resource "aws_sqs_queue" "backup_queue" {
  name                       = "${var.project}-${var.release}-backup-queue"
  visibility_timeout_seconds = "${var.backup_timeout}"
}
