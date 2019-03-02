resource "aws_sqs_queue" "restore_queue" {
  name                       = "${local.project}-${var.release}-restore-queue"
  visibility_timeout_seconds = "${var.restore_timeout}"
  delay_seconds              = "${var.restore_delay}"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.redrive_queue.arn}",
  "maxReceiveCount": ${var.restore_attempts}
}
EOF
}
