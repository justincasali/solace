resource "aws_sqs_queue" "request_queue" {
  name                       = "${local.prefix}-request-queue"
  visibility_timeout_seconds = "${var.request_timeout}"
  tags                       = "${var.tags}"
}
