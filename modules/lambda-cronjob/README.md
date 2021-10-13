# AWS Lambda

Module with AWS Lambda and CloudWatch Event trigger

## Resources

### Lambda

Lambda with source code from local.

### CloudWatch Event

## Usage

Simple example on how the module can be used.

```terraform
module "test_lambda" {
  source = "./modules/test"

  app_name      = "test"
  cron_expr     = local.cron_expr
  iam_role_name = "TestLambdaRole"

  filename = "test/test.zip"
  handler  = "test.handler"

  subnet_ids         = local.private_subnet_ids
  security_group_ids = [local.security_group_ids]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_name | Name for budget resource | `string` | n/a | yes |
| create\_iam\_setup | Controls if Budget resource would be created | `bool` | `true` | no |
| cron\_expr | CloudWatch Event cron expressions. Default is null (31 feb) | `string` | `"0/30 8-18 31 2 ? *"` | no |
| filename | Full filename for zip file | `string` | n/a | yes |
| handler | Handler name: <filename>.<function\_name> | `string` | n/a | yes |
| iam\_role\_name | IAM Role name | `string` | `""` | no |
| memory\_size | Memory to be used when running the function | `string` | `"128"` | no |
| region | AWS region | `string` | `"eu-west-1"` | no |
| runtime | Runtime | `string` | `"python3.8"` | no |
| security\_group\_ids | Security Groups | `list` | `[]` | no |
| sns\_topic\_tags | Additional tags for the SNS topic | `map(string)` | `{}` | no |
| subnet\_ids | VPC subnet group ids | `list` | `[]` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| timeout | Lambda run timeout in seconds | `string` | `"10"` | no |

## Outputs

No output.

