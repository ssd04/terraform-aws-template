[
    {
      "volumesFrom": [],
      "memory": null,
      "extraHosts": null,
      "dnsServers": null,
      "disableNetworking": null,
      "dnsSearchDomains": null,
      "entryPoint": ${task_entrypoint},
      "portMappings": [
        {
          "hostPort": ${task_hostport},
          "containerPort": ${task_containerport},
          "protocol": "tcp"
        }
      ],
      "hostname": null,
      "essential": true,
      "name": "${task_name}",
      "ulimits": null,
      "dockerSecurityOptions": null,
      "environment": [],
      "links": null,
      "workingDirectory": null,
      "readonlyRootFilesystem": null,
      "image": "${task_containerimage}",
      "command": [],
      "user": null,
      "dockerLabels": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${awslogs_group_name}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "${awslogs_group_prefix}"
        }
      },
      "cpu": null,
      "privileged": null,
      "memoryReservation": ${task_memoryreservation},
      "expanded": true
    }
]
