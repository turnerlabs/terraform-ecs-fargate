/**
 * This module adds a task definition configuration for deploying your app along with 
 * a sidecar container that writes your secrets manager secret to an ephemeral file 
 * that gets bind mounted into your app container. Note that this module is
 * dependent upon opting in to the secretsmanager.tf module.
 * 
 * You can deploy this configuration using Fargate CLI:
 * fargate service deploy -r x
 * where "x" is the revision number that this module outputs (see terraform output)
 *
 * Note that if you deploy this configuration on top of your existing app,
 * you will need to re-deploy your app (image and envvars) afterwards. 
 * If using fargate-create CLI you can run ./deploy.sh
 *
 */

variable "secret_dir" {
  type        = string
  default     = "/var/secret"
  description = "directory where secret is written"
}

variable "secret_sidecar_image" {
  type        = string
  default     = "quay.io/turner/secretsmanager-sidecar"
  description = "sidecar container that writes the secret to a file accessible by app container"
}

locals {
  secret_file = "${var.secret_dir}/${aws_secretsmanager_secret.sm_secret.name}"
  logs_group  = "/fargate/service/${var.app}-${var.environment}"
}

resource "aws_ecs_task_definition" "secrets_sidecar" {
  family                   = "${var.app}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.app_role.arn

  volume {
    name = "secret"
  }

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.container_name}",
    "image": "${var.default_backend_image}",
    "essential": true,
    "dependsOn": [
      {
        "containerName": "secrets",
        "condition": "SUCCESS"
      }
    ],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "${var.container_port}"
      },
      {
        "name": "HEALTHCHECK",
        "value": "${var.health_check}"
      },
      {
        "name": "ENABLE_LOGGING",
        "value": "false"
      },
      {
        "name": "PRODUCT",
        "value": "${var.app}"
      },
      {
        "name": "ENVIRONMENT",
        "value": "${var.environment}"
      },
      {
        "name": "SECRET",
        "value": "${local.secret_file}"
      }
    ],
    "mountPoints": [
      {
        "readOnly": true,
        "containerPath": "${var.secret_dir}",
        "sourceVolume": "secret"
      }
    ],    
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${local.logs_group}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  },
  {
    "name": "secrets",
    "image": "${var.secret_sidecar_image}",
    "essential": false,
    "environment": [
      {
        "name": "SECRET_ID",
        "value": "${aws_secretsmanager_secret.sm_secret.arn}"
      },
      {
        "name": "SECRET_FILE",
        "value": "${local.secret_file}"
      }
    ],
    "mountPoints": [
      {
        "readOnly": false,
        "containerPath": "${var.secret_dir}",
        "sourceVolume": "secret"
      }
    ],    
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${local.logs_group}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }  
]
DEFINITION

  tags = var.tags

  # avoid race condition: 
  #"Too many concurrent attempts to create a new revision of the specified family"
  depends_on = [aws_ecs_task_definition.app]
}

data "template_file" "secrets_sidecar_deploy" {
  template = <<EOF
#!/bin/bash
set -e

AWS_PROFILE=$${aws_profile}
AWS_DEFAULT_REGION=$${region}

echo "backing up running container configuration"
fargate task describe -t $${current_taskdefinition} > backup.yml

echo "deploying new sidecar configuration"
fargate service deploy -r $${sidecar_revision}

echo "re-deploying app configuration"
fargate service deploy -f backup.yml
fargate service env set -e SECRET=$${secret}
EOF

  vars = {
    aws_profile            = var.aws_profile
    region                 = var.region
    current_taskdefinition = aws_ecs_service.app.task_definition
    sidecar_revision       = split(":", aws_ecs_task_definition.secrets_sidecar.arn)[6]
    secret                 = local.secret_file
  }
}

resource "local_file" "secrets_sidecar" {
  filename = "secrets-sidecar-deploy.sh"
  content  = "${data.template_file.secrets_sidecar_deploy.rendered}"
}

# command to deploy the secrets sidecar configuration
output "deploy_secrets_sidecar" {
  value = "fargate service deploy --revision ${split(":", aws_ecs_task_definition.secrets_sidecar.arn)[6]}"
}
