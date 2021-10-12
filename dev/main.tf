terraform {
  required_version = ">= 0.12.0"

  required_providers {
    aws = ">= 2.0"
  }

  backend "s3" {
    encrypt = true
    bucket  = "<< bucket name >>"
    key     = "state"
    region  = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 3.0"
  region  = var.region
}

data "aws_caller_identity" "default" {
}

data "aws_region" "default" {
}

# Global variables
locals {
  account_id = data.aws_caller_identity.default.account_id
}
