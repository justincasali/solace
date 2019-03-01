resource "aws_sqs_queue" "error_queue" {
  name = "${var.project}-${var.release}-error-queue"
}
