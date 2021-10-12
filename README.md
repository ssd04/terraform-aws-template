# AWS Infrastructure

## Project structure

- `dev` : terraform code -> dev env
- `prod` : terraform code -> prod env
- `modules` : general terraform modules
- `lambdas` : lambda projects code
- `scripts` : useful scripts

# AWS

## AWS Resourses

### EC2

### CICD Pipeline

### Beanstalk

### Cognito

### VPC

### ACM/Route53

# Terraform

> Please make sure to run the setup in the correct AWS account, check
> AWS_PROFILE env variable

One main advantage of using the Makefile is for making sure the command are run
the correct environment.

- it can be triggered based on the command in the Makefile 
```bash
make init
make plan
make apply
```
- AWS Secrets are provided using pum python script (ADM authentication) 
```bash
make pum 
```

### Upgrade

Notes on upgrading terraform tool and also infrastructure, if there are any
major changes due to upgrade.

Follow the documentation for every major upgrade.  Usually there are step by
step instructions on how to do it.

When performing the upgrade it may happen that some variables from terraform
state are not valid anymore and they can be deleted manually. Since the state
file is stored in s3, it has to be modified on local. But these changes should
be applied carefully, make sure the s3 bucket has versioning enabled, or that
there is at least a backup file on local.

There are 2 commands that can be used for this: 
```bash
make sync-state-to-local
vim ./state  # edit file locally
make sync-state-to-s3
```

# Usefull Links

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
