variable "profile" {
  description = "AWS profile to use for deployment"
  type        = string
  default     = "<< account name >>"
}

variable "region" {
  description = "Region to deploy the resources"
  type        = string
  default     = "eu-west-1"
}

variable "app_name" {
  description = "The name of your application"
  type        = string
  default     = "test"
}
