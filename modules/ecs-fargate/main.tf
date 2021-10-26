locals {
  account_id = data.aws_caller_identity.this.account_id

  ecs_cluster_id   = element(concat(aws_ecs_cluster.this.*.id, data.aws_ecs_cluster.this.*.id, [""]), 0)
  ecs_service_name = element(concat(aws_ecs_service.ecs_service.*.name, aws_ecs_service.ecs_service_with_lb.*.name, [""]), 0)

  ecr_repo_url = element(concat(aws_ecr_repository.this.*.repository_url, list(var.ecr_repo_url), [""]), var.use_external_ecr_repo ? 1 : 0)

  task_definition_revision = max(
    element(concat(aws_ecs_task_definition.this.*.revision, data.aws_ecs_task_definition.this.*.revision, [""]), 0),
    lookup(data.external.task_revision.result, var.app_name, 0)
  )
  task_definition_name = element(concat(aws_ecs_task_definition.this.*.family, data.aws_ecs_task_definition.this.*.family, [""]), 0)
  container_definition = element(concat(data.template_file.this.*.rendered, list(var.container_definitions)), var.use_external_task_definition ? 1 : 0)

  iam_role_arn     = element(concat(aws_iam_role.this.*.arn, data.aws_iam_role.this.*.arn, [""]), 0)
  task_role_arn    = element(concat(aws_iam_role.task.*.arn, data.aws_iam_role.task.*.arn, [""]), 0)
  target_group_arn = element(concat(aws_lb_target_group.this.*.arn, data.aws_lb_target_group.this.*.arn, [""]), 0)
  lb_arn           = element(concat(aws_lb.this.*.arn, data.aws_lb.this.*.arn, [""]), 0)
}

data "aws_caller_identity" "this" {}

##############################################
# ECS
##############################################
data "aws_ecs_cluster" "this" {
  count = false == var.create_ecs_cluster ? 1 : 0

  cluster_name = "${var.ecs_cluster_name}"
}

data "aws_ecs_task_definition" "this" {
  count = false == var.create_task_definition ? 1 : 0

  task_definition = var.app_name
}

resource "aws_ecs_cluster" "this" {
  count = var.create_ecs_cluster ? 1 : 0

  name = var.ecs_cluster_name

  tags = merge(var.tags, var.ecs_cluster_tags)
}

resource "aws_ecs_service" "ecs_service_with_lb" {
  count               = var.create_ecs_service && var.create_ecs_service_with_lb ? 1 : 0
  name                = var.app_name
  cluster             = local.ecs_cluster_id
  task_definition     = "${local.task_definition_name}:${local.task_definition_revision}"
  scheduling_strategy = "REPLICA"
  launch_type         = "FARGATE"

  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_min
  deployment_maximum_percent         = var.deployment_max
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  load_balancer {
    target_group_arn = local.target_group_arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  network_configuration {
    security_groups  = var.security_groups_ids
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  tags = merge(var.tags, var.ecs_service_tags)
}

resource "aws_ecs_service" "ecs_service" {
  count               = var.create_ecs_service && false == var.create_ecs_service_with_lb ? 1 : 0
  name                = var.app_name
  cluster             = local.ecs_cluster_id
  task_definition     = "${local.task_definition_name}:${local.task_definition_revision}"
  scheduling_strategy = "REPLICA"
  launch_type         = "FARGATE"

  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_min
  deployment_maximum_percent         = var.deployment_max

  network_configuration {
    security_groups  = var.security_groups_ids
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  tags = merge(var.tags, var.ecs_service_tags)
}

resource "aws_ecs_task_definition" "this" {
  count = var.create_task_definition ? 1 : 0

  family                = var.app_name
  network_mode          = "awsvpc"
  container_definitions = local.container_definition
  execution_role_arn    = local.iam_role_arn
  task_role_arn         = local.task_role_arn

  cpu    = var.task_cpu
  memory = var.task_memory

  requires_compatibilities = ["FARGATE"]

  tags = merge(var.tags, var.task_definition_tags)
}

data "template_file" "this" {
  count = var.create_task_definition && false == var.use_external_task_definition ? 1 : 0

  template = "${file("${path.module}/templates/task_definition.tpl")}"
  vars = {
    aws_region           = var.region
    task_name            = var.app_name
    awslogs_group_name   = aws_cloudwatch_log_group.this[0].name
    awslogs_group_prefix = var.app_name
    task_entrypoint      = var.task_entrypoint
    task_hostport        = var.container_port
    task_containerport   = var.container_port
    task_containerimage  = "${local.ecr_repo_url}:${lookup(data.external.active_image_versions[0].result, var.app_name, "latest")}"

    task_memoryreservation = var.task_memory
  }
}

data "external" "task_revision" {
  # count = var.create_ecs_service && var.create_task_definition ? 1 : 0

  program = ["python", "${path.module}/scripts/get_revision.py"]

  query = {
    cluster_name = local.ecs_cluster_id
    service_name = var.app_name
  }
}

data "external" "active_image_versions" {
  count = var.create_task_definition && false == var.use_external_task_definition ? 1 : 0

  program = ["python", "${path.module}/scripts/get_image_tags.py"]

  query = {
    cluster_name = local.ecs_cluster_id
    service_name = var.app_name
  }
}

resource "aws_ecr_repository" "this" {
  name                 = var.app_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }
}

##############################################
# ALB Target Group
##############################################
data "aws_vpc" "this" {
  count = var.create_ecs_service && var.create_ecs_service_with_lb && var.create_lb_target_group ? 1 : 0

  id = var.lb_vpc_id
}

data "aws_lb" "this" {
  count = var.create_ecs_service && var.create_ecs_service_with_lb && false == var.create_lb ? 1 : 0

  name = var.lb_name
}

resource "aws_lb" "this" {
  count = var.create_ecs_service && var.create_lb && var.create_ecs_service_with_lb && var.create_lb_target_group ? 1 : 0

  name        = lookup(var.lb[count.index], "name", null)
  name_prefix = lookup(var.lb[count.index], "name_prefix", null)

  load_balancer_type = lookup(var.lb[count.index], "load_balancer_type", null)
  internal           = lookup(var.lb[count.index], "internal", null)
  security_groups    = tolist(lookup(var.lb[count.index], "security_groups", null))
  subnets            = tolist(lookup(var.lb[count.index], "subnets", null))

  idle_timeout                     = lookup(var.lb[count.index], "idle_timeout", null)
  enable_cross_zone_load_balancing = lookup(var.lb[count.index], "enable_cross_zone_load_balancing", null)
  enable_deletion_protection       = lookup(var.lb[count.index], "enable_deletion_protection", null)
  enable_http2                     = lookup(var.lb[count.index], "enable_http2", null)
  ip_address_type                  = lookup(var.lb[count.index], "ip_address_type", null)
  drop_invalid_header_fields       = lookup(var.lb[count.index], "drop_invalid_header_fields", null)

  dynamic "access_logs" {
    for_each = length(keys(lookup(var.lb[count.index], "access_logs", {}))) == 0 ? [] : [lookup(var.lb[count.index], "access_logs", {})]

    content {
      enabled = lookup(access_logs.value, "enabled", lookup(access_logs.value, "bucket", null) != null)
      bucket  = lookup(access_logs.value, "bucket", null)
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }

  dynamic "subnet_mapping" {
    for_each = length(keys(lookup(var.lb[count.index], "subnet_mapping", {}))) == 0 ? [] : [lookup(var.lb[count.index], "subnet_mapping", {})]

    content {
      subnet_id     = lookup(subnet_mapping.value.subnet_id)
      allocation_id = lookup(subnet_mapping.value, "allocation_id", null)
    }
  }

  dynamic "timeouts" {
    for_each = length(keys(lookup(var.lb[count.index], "timeouts", {}))) == 0 ? [] : [lookup(var.lb[count.index], "timeouts", {})]

    content {
      create = lookup(timeouts.value, "create", null)
      update = lookup(timeouts.value, "update", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }

  tags = merge(var.tags, var.lb_tags)
}

data "aws_lb_target_group" "this" {
  count = var.create_ecs_service && var.create_ecs_service_with_lb && false == var.create_lb_target_group ? 1 : 0

  name = var.lb_tg_name
}

resource "aws_lb_target_group" "this" {
  count = var.create_ecs_service && var.create_ecs_service_with_lb && var.create_lb_target_group ? 1 : 0

  name        = lookup(var.target_group[count.index], "name", null)
  name_prefix = lookup(var.target_group[count.index], "name_prefix", null)

  vpc_id      = data.aws_vpc.this[0].id
  port        = lookup(var.target_group[count.index], "backend_port", null)
  protocol    = lookup(var.target_group[count.index], "backend_protocol", null) != null ? upper(lookup(var.target_group[count.index], "backend_protocol")) : null
  target_type = lookup(var.target_group[count.index], "target_type", null)

  deregistration_delay               = lookup(var.target_group[count.index], "deregistration_delay", null)
  slow_start                         = lookup(var.target_group[count.index], "slow_start", null)
  proxy_protocol_v2                  = lookup(var.target_group[count.index], "proxy_protocol_v2", false)
  lambda_multi_value_headers_enabled = lookup(var.target_group[count.index], "lambda_multi_value_headers_enabled", false)
  load_balancing_algorithm_type      = lookup(var.target_group[count.index], "load_balancing_algorithm_type", null)

  depends_on = [local.lb_arn]

  dynamic "health_check" {
    for_each = length(keys(lookup(var.target_group[count.index], "health_check", {}))) == 0 ? [] : [lookup(var.target_group[count.index], "health_check", {})]

    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  dynamic "stickiness" {
    for_each = length(keys(lookup(var.target_group[count.index], "stickiness", {}))) == 0 ? [] : [lookup(var.target_group[count.index], "stickiness", {})]

    content {
      enabled         = lookup(stickiness.value, "enabled", null)
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      type            = lookup(stickiness.value, "type", null)
    }
  }
}

resource "aws_alb_listener" "this" {
  count = var.create_ecs_service && var.create_ecs_service_with_lb && var.create_lb_target_group && var.create_lb ? 1 : 0

  load_balancer_arn = local.lb_arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol
  certificate_arn   = var.lb_listener_certificate_arn

  default_action {
    target_group_arn = local.target_group_arn
    type             = "forward"
  }
}

##############################################
# CloudWatch
##############################################
resource "aws_cloudwatch_log_group" "this" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "${var.app_name}-log-group"
  retention_in_days = var.cloudwatch_log_group_retention
}
