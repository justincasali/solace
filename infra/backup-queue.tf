resource "aws_sqs_queue" "backup_queue" {
  name                       = "${var.project}-${var.release}-backup-queue"
  visibility_timeout_seconds = "${var.backup_task["timeout"]}"
  delay_seconds              = "${var.backup_task["delay"]}"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.redrive_queue.arn}",
  "maxReceiveCount": ${var.backup_task["count"]}
}
EOF
}
