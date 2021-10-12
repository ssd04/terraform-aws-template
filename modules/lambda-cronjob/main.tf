data "aws_caller_identity" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id

  iam_role_arn = element(concat(aws_iam_role.this.*.arn, data.aws_iam_role.this.*.arn, [""]), 0)
  cron_expr    = var.cron_expr
}

resource "aws_lambda_function" "this" {
  filename      = var.filename
  function_name = var.app_name

  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  source_code_hash = filebase64sha256(var.filename)

  role = local.iam_role_arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  dynamic "environment" {
    for_each = var.env_vars == null ? [] : [var.env_vars]
    content {
      variables = var.env_vars
    }
  }

  # environment {
  #   variables = var.env_vars
  # }
}

resource "aws_cloudwatch_event_rule" "trigger" {
  name                = "${var.app_name}-trigger"
  schedule_expression = "cron(${local.cron_expr})"
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.trigger.name
  arn  = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger.arn
}
