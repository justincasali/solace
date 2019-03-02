resource "aws_sqs_queue" "request_queue" {
  name                       = "${local.project}-${var.env}-request-queue"
  visibility_timeout_seconds = "${var.request_timeout}"
}
