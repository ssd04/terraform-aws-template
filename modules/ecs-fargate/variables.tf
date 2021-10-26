variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "app_name" {
  description = "Name for the app"
  type        = string
}

# Create Flags
variable "create_ecs_cluster" {
  description = "Controls if ECS cluster would be created"
  type        = bool
  default     = true
}

variable "create_task_definition" {
  description = "Controls if Task definition would be created"
  type        = bool
  default     = true
}

variable "create_ecs_service" {
  description = "Controls if ECS service would be created"
  type        = bool
  default     = true
}

variable "create_ecs_service_with_lb" {
  description = "Controls if ECS service would be attached to a load balancer"
  type        = bool
  default     = true
}

variable "create_iam_setup" {
  description = "Controls if IAM role and policy would be created"
  type        = bool
  default     = true
}

variable "create_task_role" {
  description = "Controls if IAM task role and policy would be created"
  type        = bool
  default     = true
}

variable "create_cloudwatch_log_group" {
  description = "Controls if CloudWatch Log Group would be created"
  type        = bool
  default     = true
}

variable "create_lb_target_group" {
  description = "Controls if Target Group for ALB would be created"
  type        = bool
  default     = true
}

variable "create_lb" {
  description = "Controls if Target Group for ALB would be created"
  type        = bool
  default     = true
}

variable "use_external_task_definition" {
  description = "Controls if using an external task definition or not"
  type        = bool
  default     = false
}

# ECS
variable "ecs_cluster_name" {
  description = "Name for the app"
  type        = string
}

variable "iam_role_name" {
  description = "IAM role for the Task Definition Execution. This is requited only if create_iam_setup is false."
  type        = string
  default     = "null"
}

variable "task_role_name" {
  description = "IAM Task role for the Task Definition. This is requited only if create_task_role is false."
  type        = string
  default     = "null"
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "deployment_min" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 100
}

variable "deployment_max" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 200
}

variable "health_check_grace_period_seconds" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 180
}

variable "security_groups_ids" {
  description = "The security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used."
  type        = list
  default     = []
}

variable "subnet_ids" {
  description = "The subnets associated with the task or servic"
  type        = list
  default     = []
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false"
  type        = bool
  default     = false
}

variable "task_name" {
  description = "Name for task definition"
  type        = string
}

variable "task_cpu" {
  description = "The number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "The amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required"
  type        = number
  default     = 2048
}

variable "container_port" {
  description = "The port on the container to associate with the load balancer."
  type        = number
  default     = 8080
}

variable "container_definitions" {
  description = "The JSON config for containers in task definition."
  type        = string
  default     = null
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE"
  type        = string
  default     = "MUTABLE"
}

variable "task_entrypoint" {
  description = ""
  type        = string
  default     = "null"
}

variable "use_external_ecr_repo" {
  description = "Controls if using an external ecr repository or not"
  type        = bool
  default     = false
}
variable "ecr_repo_url" {
  description = ""
  type        = string
  default     = "null"
}

# CloudWatch
variable "cloudwatch_log_group_retention" {
  description = "CloudWatch Log Group retention in days"
  type        = number
  default     = 7
}

# ALB Target Group
variable "lb_vpc_id" {
  description = "VPC ID that will be used for Target Group"
  type        = string
  default     = ""
}

variable "lb" {
  description = "A list of maps containing key/value pairs that define the lb to be created. Required key/values: name, bucket, subnet_id"
  type        = list
  default     = []
}

variable "target_group" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Required key/values: name, backend_protocol, backend_port"
  type        = list
  default     = []
}

variable "lb_listener_port" {
  description = ""
  type        = string
  default     = "443"
}

variable "lb_listener_protocol" {
  description = ""
  type        = string
  default     = "HTTPS"
}

variable "lb_listener_certificate_arn" {
  description = ""
  type        = string
  default     = ""
}

variable "lb_tg_name" {
  description = "The name for Target Group corresponding with the Load Balancer."
  type        = string
  default     = ""
}

variable "lb_name" {
  description = "The name for the Load Balancer."
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "ecs_cluster_tags" {
  description = "Additional tags for ECS cluster"
  type        = map(string)
  default     = {}
}

variable "ecs_service_tags" {
  description = "Additional tags for ECS Service"
  type        = map(string)
  default     = {}
}

variable "task_definition_tags" {
  description = "Additional tags for the task definition"
  type        = map(string)
  default     = {}
}

variable "lb_tags" {
  description = "Additional tags for the lb"
  type        = map(string)
  default     = {}
}
