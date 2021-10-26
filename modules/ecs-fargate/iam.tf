######################################
# Task Execution Role
######################################

data "aws_iam_role" "this" {
  count = false == var.create_iam_setup ? 1 : 0

  name = var.iam_role_name
}

resource "aws_iam_role" "this" {
  count = var.create_iam_setup ? 1 : 0

  name               = "${var.app_name}-TaskExecutionRole"
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
        "ecs-tasks.amazonaws.com",
        "lambda.amazonaws.com",
        "ssm.amazonaws.com"
      ]
    }
    effect = "Allow"
  }
}

resource "aws_iam_policy" "this" {
  count = var.create_iam_setup ? 1 : 0

  name   = "${var.app_name}-TaskExecutionPolicy"
  policy = data.aws_iam_policy_document.permissions_policy.json
}

data "aws_iam_policy_document" "permissions_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/*",
      "arn:aws:kms:${var.region}:${local.account_id}:key/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_role" {
  count = var.create_iam_setup ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_role2" {
  count = var.create_iam_setup ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

######################################
# Task Role
######################################

data "aws_iam_role" "task" {
  count = false == var.create_task_role ? 1 : 0

  name = var.task_role_name
}

resource "aws_iam_role" "task" {
  count = var.create_task_role ? 1 : 0

  name               = "${var.app_name}-TaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy2.json
}

data "aws_iam_policy_document" "assume_role_policy2" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
    effect = "Allow"
  }
}

resource "aws_iam_policy" "task" {
  count = var.create_task_role ? 1 : 0

  name   = "${var.app_name}-TaskPolicy"
  policy = data.aws_iam_policy_document.permissions_policy2.json
}

data "aws_iam_policy_document" "permissions_policy2" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "s3:*",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/*",
      "arn:aws:kms:${var.region}:${local.account_id}:key/*",
      "arn:aws:s3:::*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_role_task" {
  count = var.create_task_role ? 1 : 0

  role       = aws_iam_role.task[0].name
  policy_arn = aws_iam_policy.task[0].arn
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_role_task2" {
  count = var.create_iam_setup ? 1 : 0

  role       = aws_iam_role.task[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
