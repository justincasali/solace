resource "aws_sqs_queue" "redrive_queue" {
  name                       = "${local.project}-${var.release}-redrive-queue"
  visibility_timeout_seconds = "${var.redrive_timeout}"
}
