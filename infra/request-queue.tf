resource "aws_sqs_queue" "request_queue" {
  name                       = "${var.project}-${var.release}-request-queue"
  visibility_timeout_seconds = "${var.request_timeout}"
}
