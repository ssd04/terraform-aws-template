# ##################
# Manage Terraform
# ##################

SHELL := /bin/bash

aws_profile = "<< aws profile name >>"
export AWS_PROFILE := $(aws_profile)
aws_account_id = $(shell aws sts get-caller-identity | jq -r '.Account')

python = $(shell which python3)

TF_VERSION = 0.13.0
#terraform = docker run -it --rm -v $(HOME):/root -v $(PWD):/workspace -w /workspace hashicorp/terraform:$(TF_VERSION)
terraform = $(shell which terraform)
#terraform-docs = docker run --rm -it -v $(pwd):/workspace -w /workspace quay.io/terraform-docs/terraform-docs:0.10.1 markdown
terraform-docs = $(shell which terraform-docs)

.DEFAULT_GOAL := help

.PHONY: help get init plan apply destroy state import terraform log module-doc
help:
	@printf ""

get:
	$(terraform) get -update

init: get
	$(terraform) init -var-file=variables.tfvars

plan:
	$(terraform) plan -var-file=variables.tfvars

apply:
	$(terraform) apply -var-file=variables.tfvars

destroy:
	$(terraform) destroy -var-file=variables.tfvars

state:
	$(terraform) state $(filter-out $@,$(MAKECMDGOALS))

import:
	$(terraform) import $(filter-out $@,$(MAKECMDGOALS))

terraform:
	$(terraform) $(filter-out $@,$(MAKECMDGOALS))

%:
    @:

.PHONY: log
log:
	@echo Enable logging
	export TF_LOG=DEBUG
	export TF_LOG_PATH=/tmp/log

.PHONY: module-doc
module-doc:
	$(terraform-docs) . >> readme.md


# ##############################
# AWS
# ##############################
.PHONY: ecr-login ecr-push

ecr-login:
	aws ecr get-login-password \
		--region $(aws_region) \
		| docker login \
		--username AWS --password-stdin \
		$(aws_account_id).dkr.ecr.$(aws_region).amazonaws.com

image = "maven"
image_tag = $(shell docker images --format "{{.Tag}}" $(image) | head -n 1)

ecr-push:
	docker tag $(image):$(image_tag) $(aws_account_id).dkr.ecr.$(aws_region).amazonaws.com/$(image):$(image_tag)
	docker push $(aws_account_id).dkr.ecr.$(aws_region).amazonaws.com/$(image):$(image_tag)
	docker rmi $(aws_account_id).dkr.ecr.$(aws_region).amazonaws.com/$(image):$(image_tag)


sync-state-to-local:
	aws s3 sync s3://remote-state-name ./state

sync-state-to-s3:
	aws s3 sync ./state s3://remote-state-name
