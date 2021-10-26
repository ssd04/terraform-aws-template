# ECS Fargate

This module creates the infrastructure for running ECS using Fargate in AWS.

## Resources

### ECS

ECS Cluster, Service and Task Definition can be created.
There is a boolean variable that specifies if a Service with ALB would be create or not.
Since there can be multiple services in one ECS cluster, a variable for specifying wether to create or use an existing one is availale.
Also, since the Task definition is very specific for each solution, there is a option to setup and external task definition, instead of using the default one.

### Cloudwatch Log Group

A Cloudwatch Log Group can be created to be used for task logs.

### ALB Target Group

If the ECS Service is setup to use a Load Balancer, there are variables for specifying an already existing ALB or creating a new. This can be tricky since the LB is mainly a "global" resource, it can be used for multiple services. It is recommended to use an existing one, if the solution might require multiple services in time.

## Usage

Example with ALB, Target Group and default task definition setup
```terraform
module "ecs_test" {
  source = "../modules/ecs-fargate"

  app_name = var.app_name

  create_ecs_service_with_lb  = true
  create_cloudwatch_log_group = true
  create_iam_setup            = true

  security_groups_ids = local.security_groups_ids   # this is a list []
  subnet_ids          = data.aws_subnet_ids.private_subnets.ids

  assign_public_ip = false
  ecs_cluster_name = "dsa-test-cluster"

  iam_role_name  = "dsa-ecs-role"
  container_port = aws_ssm_parameter.port.value
  task_name      = var.app_name
  lb_tg_name     = "dsa-test-target-group"
  lb_name        = "dsa-test-lb"
  lb_vpc_id      = local.vpc_id

  lb = [
    {
      name            = "dsa-test-lb"
      subnets         = data.aws_subnet_ids.public_subnets.ids
      security_groups = local.security_groups_ids
    }
  ]

  target_group = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = aws_ssm_parameter.port.value
      target_type      = "ip"
    }
  ]

  lb_listener_port            = 443
  lb_listener_protocol        = "HTTPS"
  lb_listener_certificate_arn = ""
}
```

Example with ALB, Target Group and external task definition setup
```terraform
module "ecs_test" {
  source = "../modules/ecs-fargate"

  app_name = var.app_name

  create_ecs_service_with_lb  = true
  create_cloudwatch_log_group = true
  create_iam_setup            = true

  security_groups_ids = local.security_groups_ids   # this is a list []
  subnet_ids          = data.aws_subnet_ids.private_subnets.ids

  assign_public_ip = false
  ecs_cluster_name = "test-cluster"

  iam_role_name  = "test-ecs-role"
  container_port = aws_ssm_parameter.port.value
  task_name      = var.app_name
  lb_tg_name     = "test-target-group"
  lb_name        = "test-lb"
  lb_vpc_id      = local.vpc_id

  use_external_task_definition = true
  container_definitions        = data.template_file.this.rendered

  lb = [
    {
      name            = "test-lb"
      subnets         = data.aws_subnet_ids.public_subnets.ids
      security_groups = local.security_groups_ids
    }
  ]

  target_group = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = aws_ssm_parameter.port.value
      target_type      = "ip"
    }
  ]

  lb_listener_port            = 443
  lb_listener_protocol        = "HTTPS"
  lb_listener_certificate_arn = ""
}

data "template_file" "this" {
  template = "${file("${path.root}/templates/task_definition.tpl")}"
  vars = {
    aws_region             = var.region
    aws_account_id         = local.account_id
    ...
  }
}
```

Example setup without creating ALB and Target Group, but referencing an already existing Target Group
```terraform
module "ecs_test" {
  source = "../modules/ecs-fargate"

  app_name = var.app_name

  create_ecs_service_with_lb  = true
  create_cloudwatch_log_group = true
  create_iam_setup            = true
  create_lb_target_group      = false

  security_groups_ids = local.security_groups_ids   # this is a list []
  subnet_ids          = data.aws_subnet_ids.public_subnets.ids

  assign_public_ip = false
  ecs_cluster_name = "dsa-test-cluster"

  iam_role_name  = "dsa-ecs-role"
  container_port = aws_ssm_parameter.port.value
  task_name      = var.app_name
  lb_tg_name     = "dsa-test-target-group"

  use_external_task_definition = false
  container_definitions        = data.template_file.this.rendered
}
```

Example setup without ALB and Target Group, but with public ip

```terraform
module "ecs_test" {
  source = "../modules/ecs-fargate"

  app_name = var.app_name

  create_ecs_service_with_lb  = false
  create_cloudwatch_log_group = true
  create_iam_setup            = true

  security_groups_ids = local.security_groups_ids
  subnet_ids          = data.aws_subnet_ids.public_subnets.ids

  assign_public_ip = true
  ecs_cluster_name = "test-cluster"

  iam_role_name  = "test-ecs-role"
  container_port = aws_ssm_parameter.port.value
  task_name      = var.app_name
}
```

# Refs

- [Troubleshooting](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 2.7 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7 |
| external | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_name | Name for the app | `string` | n/a | yes |
| assign\_public\_ip | Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false | `bool` | `false` | no |
| cloudwatch\_log\_group\_retention | CloudWatch Log Group retention in days | `number` | `7` | no |
| container\_definitions | The JSON config for containers in task definition. | `string` | `null` | no |
| container\_port | The port on the container to associate with the load balancer. | `number` | n/a | yes |
| create\_cloudwatch\_log\_group | Controls if CloudWatch Log Group would be created | `bool` | `true` | no |
| create\_ecs\_cluster | Controls if ECS cluster would be created | `bool` | `true` | no |
| create\_ecs\_service\_with\_lb | Controls if Task definition would be created | `bool` | `true` | no |
| create\_iam\_setup | Controls if IAM role and policy would be created | `bool` | `true` | no |
| create\_lb | Controls if Target Group for ALB would be created | `bool` | `true` | no |
| create\_lb\_target\_group | Controls if Target Group for ALB would be created | `bool` | `true` | no |
| create\_task\_definition | Controls if Task definition would be created | `bool` | `true` | no |
| deployment\_max | The number of instances of the task definition to place and keep running | `number` | `200` | no |
| deployment\_min | The number of instances of the task definition to place and keep running | `number` | `100` | no |
| desired\_count | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| ecs\_cluster\_name | Name for the app | `string` | n/a | yes |
| ecs\_cluster\_tags | Additional tags for ECS cluster | `map(string)` | `{}` | no |
| ecs\_service\_tags | Additional tags for ECS Service | `map(string)` | `{}` | no |
| health\_check\_grace\_period\_seconds | The number of instances of the task definition to place and keep running | `number` | `180` | no |
| iam\_role\_name | Name for the app | `string` | n/a | yes |
| image\_tag\_mutability | The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE | `string` | `"MUTABLE"` | no |
| lb | A list of maps containing key/value pairs that define the lb to be created. Required key/values: name, bucket, subnet\_id | `list` | `[]` | no |
| lb\_listener\_certificate\_arn | n/a | `string` | `""` | no |
| lb\_listener\_port | n/a | `string` | `"443"` | no |
| lb\_listener\_protocol | n/a | `string` | `"HTTPS"` | no |
| lb\_name | The name for the Load Balancer. | `string` | `""` | no |
| lb\_tags | Additional tags for the lb | `map(string)` | `{}` | no |
| lb\_tg\_name | The name for Target Group corresponding with the Load Balancer. | `string` | `""` | no |
| lb\_vpc\_id | VPC ID that will be used for Target Group | `string` | `""` | no |
| region | AWS region | `string` | `"eu-west-1"` | no |
| security\_groups\_ids | The security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used. | `list` | `[]` | no |
| subnet\_ids | The subnets associated with the task or servic | `list` | `[]` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| target\_group | A list of maps containing key/value pairs that define the target groups to be created. Required key/values: name, backend\_protocol, backend\_port | `list` | `[]` | no |
| task\_cpu | The number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required | `number` | `1024` | no |
| task\_definition\_tags | Additional tags for the task definition | `map(string)` | `{}` | no |
| task\_entrypoint | n/a | `string` | `"null"` | no |
| task\_memory | The amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required | `number` | `2048` | no |
| task\_name | Name for task definition | `string` | n/a | yes |
| use\_external\_task\_definition | Controls if using an external task definition or not | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_log\_group\_name | Name of cloudwatch log group |
| ecr\_repository | Repository URL |
| ecs\_cluster\_name | n/a |
| ecs\_service\_name | n/a |
| lb\_arn | The ARN of the load balancer we created. |
| lb\_id | The ID of the load balancer we created. |
| target\_group\_arn | ARN of the target group. Useful for passing to your Auto Scaling group. |
| target\_group\_arn\_suffixes | ARN suffixes of our target groups - can be used with CloudWatch. |
| target\_group\_name | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |

