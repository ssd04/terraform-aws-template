data "aws_iam_role" "this" {
  count = false == var.create_iam_setup ? 1 : 0

  name = var.iam_role_name
}

resource "aws_iam_role" "this" {
  count = var.create_iam_setup ? 1 : 0

  name = var.iam_role_name

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "ssm.amazonaws.com",
        "s3.amazonaws.com",
      ]
    }
    effect = "Allow"
  }
}

resource "aws_iam_policy" "this" {
  count = var.create_iam_setup ? 1 : 0

  name   = "${var.app_name}-LambdaPolicy"
  policy = data.aws_iam_policy_document.permissions_policy.json
}

data "aws_iam_policy_document" "permissions_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
      "sns:Publish",
      "sns:ListTopics",
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListObjects"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter/*",
      "arn:aws:kms:${var.region}:${var.account_id}:key/*",
      "arn:aws:sns:${var.region}:${var.account_id}:*",
      "arn:aws:rds:${var.region}:${var.account_id}:*",
      "arn:aws:s3:::*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_role" {
  count = var.create_iam_setup ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}


resource "aws_iam_role_policy_attachment" "vpc-policy" {
  count = var.create_iam_setup ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
