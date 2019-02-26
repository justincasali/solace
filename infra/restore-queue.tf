resource "aws_sqs_queue" "restore_queue" {
  name                       = "${var.project}-${var.release}-restore-queue"
  visibility_timeout_seconds = "${var.restore_timeout}"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.restore_dead_letter_queue.arn}",
  "maxReceiveCount": ${var.restore_count}
}
EOF
}

resource "aws_sqs_queue" "restore_dead_letter_queue" {
  name = "${var.project}-${var.release}-restore-dead-letter-queue"
}
