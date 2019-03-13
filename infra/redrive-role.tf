resource "aws_iam_role" "redrive_lambda_role" {
  name               = "${local.prefix}-redrive-lambda-role"
  assume_role_policy = "${data.aws_iam_policy_document.redrive_lambda_sts_policy.json}"
  tags               = "${var.tags}"
}

resource "aws_iam_role_policy_attachment" "redrive_lambda_execution_access" {
  role       = "${aws_iam_role.redrive_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "redrive_lambda_resource_access" {
  name   = "redrive-lambda-resource-access"
  role   = "${aws_iam_role.redrive_lambda_role.name}"
  policy = "${data.aws_iam_policy_document.redrive_lambda_resource_policy.json}"
}

data "aws_iam_policy_document" "redrive_lambda_sts_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "redrive_lambda_resource_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:*",
    ]

    resources = [
      "${aws_sqs_queue.redrive_queue.arn}",
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
