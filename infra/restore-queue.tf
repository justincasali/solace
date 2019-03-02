resource "aws_sqs_queue" "restore_queue" {
  name                       = "${var.project}-${var.release}-restore-queue"
  visibility_timeout_seconds = "${var.restore_queue["timeout"]}"
  delay_seconds              = "${var.restore_queue["delay"]}"

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.redrive_queue.arn}",
  "maxReceiveCount": ${var.restore_queue["count"]}
}
EOF
}
