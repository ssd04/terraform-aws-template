import argparse
import ast
import json
import os
import logging
import sys

import boto3
from botocore.exceptions import ClientError
from botocore.config import Config

aws_region = os.environ.get("AWS_REGION")
config = Config(retries={"max_attempts": 0, "mode": "adaptive"})


def handler(event, context):
    body = {
        "message": "Simple test! Your function executed successfully!",
        "input": event,
    }

    response = {"statusCode": 200, "body": json.dumps(body)}

    return response


if __name__ == "__main__":
    handler()
