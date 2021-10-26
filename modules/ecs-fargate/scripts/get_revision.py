#!/usr/bin/env python

""" Return revision for ECS task definition """
import json
import sys
import boto3

ECR_CLIENT = boto3.client("ecr")
ECS_CLIENT = boto3.client("ecs")


def main(cluster_name, service_name):
    """The main routine"""

    service = ECS_CLIENT.describe_services(
        cluster=cluster_name, services=[service_name]
    )

    revision = {}
    if not service["services"]:
        # service doesn't exist yet, return empty dict
        return revision

    task_definition_arn = service["services"][0]["taskDefinition"]
    task_definition = ECS_CLIENT.describe_task_definition(
        taskDefinition=task_definition_arn
    )

    task_revision = task_definition["taskDefinition"]["revision"]
    task_family = task_definition["taskDefinition"]["family"]
    revision[task_family] = str(task_revision)

    return revision


if __name__ == "__main__":
    args = json.load(sys.stdin)

    cluster_name = args["cluster_name"]
    service_name = args["service_name"]

    revision = main(cluster_name, service_name)
    print(json.dumps(revision))
