resource "aws_sqs_queue" "backup_queue" {
  name                       = "${var.project}-${var.release}-backup-queue"
  visibility_timeout_seconds = "${var.backup_queue["timeout"]}"
  delay_seconds              = "${var.backup_queue["delay"]}"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.redrive_queue.arn}",
  "maxReceiveCount": ${var.backup_queue["count"]}
}
EOF
}
