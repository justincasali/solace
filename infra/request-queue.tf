resource "aws_sqs_queue" "request_queue" {
  name                       = "${var.project}-${var.release}-request-queue"
  visibility_timeout_seconds = "${var.request_timeout}"

  # policy = "allow different accounts / regions access"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.request_dead_letter_queue.arn}",
  "maxReceiveCount": 1
}
EOF
}

resource "aws_sqs_queue" "request_dead_letter_queue" {
  name = "${var.project}-${var.release}-request-dead-letter-queue"
}
