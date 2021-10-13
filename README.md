# AWS Infrastructure

This setup structure is useful for small to medium sized AWS projects, where
prod and development/testing environments are handled in a different terraform
state.

Common terraform modules can be used both environments.

It is important to find the right balance between the complexity and the level
of abstractions created through modules. Use modules only when necessary (only
when a clear pattern is repeated more than three times)

## Project structure

- `dev` : terraform code -> dev env
- `prod` : terraform code -> prod env
- `modules` : general terraform modules
- `lambdas` : lambda projects code
- `scripts` : useful scripts

## Prerequisites

- Linux environment
- terraform
- terraform-docs
- make

# AWS

Decribe briefly the aws resources.

## Compute resources

## Deployment

## Networking

## Security

# Terraform

> Please make sure to run the setup in the correct AWS account, check
> AWS_PROFILE env variable

One main advantage of using the Makefile is for making sure the commands are run in
the correct environment.

There is a separate `Makefile` for each environment.

Terraform can be triggered based on the commands in the Makefile 
```bash
make init
make plan
make apply
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
