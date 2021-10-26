""" Return image tags specified in ECS task definition """
import json
import sys
import boto3

ECR_CLIENT = boto3.client("ecr")
ECS_CLIENT = boto3.client("ecs")


def main(cluster_name, service_name):
    """The main routine"""

    image_versions = {}
    service = ECS_CLIENT.describe_services(
        cluster=cluster_name, services=[service_name]
    )

    if not service["services"]:
        # service doesn't exist yet, return empty dict
        return image_versions

    task_definition_arn = service["services"][0]["taskDefinition"]
    task_definition = ECS_CLIENT.describe_task_definition(
        taskDefinition=task_definition_arn
    )

    for container in task_definition["taskDefinition"]["containerDefinitions"]:
        full_name = container["image"].split(":")
        # only add to response if image contains tag
        if len(full_name) > 1:
            image_versions[container["name"]] = full_name[1]

    return image_versions


if __name__ == "__main__":
    args = json.load(sys.stdin)
    cluster_name = args["cluster_name"]
    service_name = args["service_name"]

    image_versions = main(cluster_name, service_name)
    print(json.dumps(image_versions))
