resource "aws_sqs_queue" "restore_queue" {
  name                       = "${local.prefix}-restore-queue"
  visibility_timeout_seconds = "${var.restore_timeout}"
  delay_seconds              = "${var.restore_spacing}"
  tags                       = "${var.tags}"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.redrive_queue.arn}",
  "maxReceiveCount": ${var.restore_attempts}
}
EOF
}
