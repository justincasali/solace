resource "aws_sqs_queue" "restore_queue" {
  name                       = "${var.project}-${var.release}-restore-queue"
  visibility_timeout_seconds = "${var.restore_timeout}"
}
