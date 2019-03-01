resource "aws_sqs_queue" "redrive_queue" {
  name                       = "${var.project}-${var.release}-redrive-queue"
  visibility_timeout_seconds = "${var.redrive_timeout}"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.graveyard_queue.arn}",
  "maxReceiveCount": 1
}
EOF
}
