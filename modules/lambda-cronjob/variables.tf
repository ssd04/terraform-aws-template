variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "app_name" {
  description = "Name for budget resource"
  type        = string
}

variable "account_id" {
  description = "AWS Account id"
  type        = string
}

variable "create_iam_setup" {
  description = "Controls if Budget resource would be created"
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "IAM Role name"
  type        = string
  default     = ""
}

variable "cron_expr" {
  description = "CloudWatch Event cron expressions. Default is null (31 feb)"
  type        = string
  default     = "0/30 8-18 31 2 ? *"
}

variable "subnet_ids" {
  description = "VPC subnet group ids"
  type        = list
  default     = []
}

variable "security_group_ids" {
  description = "Security Groups"
  type        = list
  default     = []
}

variable "filename" {
  description = "Full filename for zip file"
  type        = string
}

variable "handler" {
  description = "Handler name: <filename>.<function_name>"
  type        = string
}

variable "runtime" {
  description = "Runtime"
  type        = string
  default     = "python3.8"
}

variable "timeout" {
  description = "Lambda run timeout in seconds"
  type        = string
  default     = "10"
}

variable "memory_size" {
  description = "Memory to be used when running the function"
  type        = string
  default     = "128"
}

variable "env_vars" {
  description = "A set of environment variables"
  type        = map(string)
  default     = null
}

# Tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
