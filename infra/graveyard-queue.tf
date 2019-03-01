resource "aws_sqs_queue" "graveyard_queue" {
  name = "${var.project}-${var.release}-graveyard-queue"
}
