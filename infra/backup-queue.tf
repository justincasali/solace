resource "aws_sqs_queue" "backup_queue" {
  name                       = "${local.prefix}-backup-queue"
  visibility_timeout_seconds = "${var.backup_timeout}"
  delay_seconds              = "${var.backup_spacing}"
  tags                       = "${var.tags}"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.redrive_queue.arn}",
  "maxReceiveCount": ${var.backup_attempts}
}
EOF
}
