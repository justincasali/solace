resource "aws_sqs_queue" "backup_queue" {
  name                       = "${var.project}-${var.release}-backup-queue"
  visibility_timeout_seconds = "${var.backup_timeout}"
  delay_seconds              = "${var.backup_delay}"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.backup_dead_letter_queue.arn}",
  "maxReceiveCount": ${var.backup_count}
}
EOF
}

resource "aws_sqs_queue" "backup_dead_letter_queue" {
  name = "${var.project}-${var.release}-backup-dead-letter-queue"
}
