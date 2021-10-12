terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0"
    }
  }

  backend "s3" {
    bucket = "vfs-prod-account-state"
    key    = "state"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 2.0"
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
