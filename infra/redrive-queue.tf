resource "aws_sqs_queue" "redrive_queue" {
  name                       = "${local.prefix}-redrive-queue"
  visibility_timeout_seconds = "${var.redrive_timeout}"
}
