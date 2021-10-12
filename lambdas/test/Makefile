########################################
# Manage AWS Lambda function
########################################

SHELL := $(shell which bash)

aws_profile = "<< aws profile name >>"
export AWS_PROFILE := $(aws_profile)

python = $(shell which python3)

name = test
function_file = test.py
handler = test.handler
timeout = 5

help:
	@echo -e ""
	@echo -e "Manage AWS Lambda function.\n"
	@echo -e "Available command:"
	@echo -e "\tinstall\tInstall python dependencies"
	@echo -e "\tbuild\tBuild the package into zip file"
	@echo -e "\trun\tInvoke the lambda function"
	@echo -e "\tpush\tUpdate function code"
	@echo -e "\tconf\tConfigure handler name(module.funtion) and timeout"
	@echo -e "\ttest\tRun the code locally"
	@echo -e ""

pum:
	$(python) $(pum_script) -p $(aws_profile)

install:
	pip3 install -r requirements.txt --target ./package
	cd package && zip -r9 ../${name}.zip *

build:
	zip -g ${name}.zip $(function_file)

run:
	aws lambda invoke --function-name $(name) out --log-type Tail --query 'LogResult' --output text |  base64 -d

push: build
	aws lambda update-function-code --function-name $(name) --zip-file fileb://${name}.zip

push-s3:
	aws s3 cp ${name}.zip s3://$(S3_BUCKET)
	aws lambda update-function-code --function-name $(name) --s3-bucket $(S3_BUCKET) --s3-key $(S3_KEY) --publish

conf:
	aws lambda update-function-configuration --function-name $(name) --handler $(handler) --timeout $(timeout)

test:
	$(python) $(function_file)
