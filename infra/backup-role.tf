resource "aws_iam_role" "backup_lambda_role" {
  name               = "${local.prefix}-backup-lambda-role"
  assume_role_policy = "${data.aws_iam_policy_document.backup_lambda_sts_policy.json}"
}

resource "aws_iam_role_policy_attachment" "backup_lambda_execution_access" {
  role       = "${aws_iam_role.backup_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "backup_lambda_resource_access" {
  name   = "backup-lambda-resource-access"
  role   = "${aws_iam_role.backup_lambda_role.name}"
  policy = "${data.aws_iam_policy_document.backup_lambda_resource_policy.json}"
}

data "aws_iam_policy_document" "backup_lambda_sts_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "backup_lambda_resource_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:*",
    ]

    resources = [
      "${aws_sqs_queue.backup_queue.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "${aws_dynamodb_table.backup_table.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = [
      "*",
    ]
  }
}
