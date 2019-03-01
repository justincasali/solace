resource "aws_iam_role" "graveyard_lambda_role" {
  name               = "${var.project}-${var.release}-graveyard-lambda-role"
  assume_role_policy = "${data.aws_iam_policy_document.graveyard_lambda_sts_policy.json}"
}

resource "aws_iam_role_policy_attachment" "graveyard_lambda_execution_access" {
  role       = "${aws_iam_role.graveyard_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "graveyard_lambda_resource_access" {
  name   = "graveyard-lambda-resource-access"
  role   = "${aws_iam_role.graveyard_lambda_role.name}"
  policy = "${data.aws_iam_policy_document.graveyard_lambda_resource_policy.json}"
}

data "aws_iam_policy_document" "graveyard_lambda_sts_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "graveyard_lambda_resource_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:*",
    ]

    resources = [
      "${aws_sqs_queue.graveyard_queue.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "${aws_dynamodb_table.backup_table.arn}",
      "${aws_dynamodb_table.restore_table.arn}",
    ]
  }
}