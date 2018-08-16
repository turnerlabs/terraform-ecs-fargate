# Environment Dev Terraform

Creates the dev environment's infrastructure. These templates are designed to be customized.  
The optional components can be removed by simply deleting the `.tf` file.


## Components

| Name | Description | Optional |
|------|-------------|:----:|
| [main.tf][edm] | Terrform remote state, AWS provider, output |  |
| [ecs.tf][ede] | ECS Cluster, Service, Task Definition, ecsTaskExecutionRole, CloudWatch Log Group |  |
| [lb.tf][edl] | ALB, Target Group, S3 bucket for access logs  |  |
| [nsg.tf][edn] | NSG for ALB and Task |  |
| [lb-http.tf][edlhttp] | HTTP listener, NSG rule. Delete if HTTPS only | Yes |
| [lb-https.tf][edlhttps] | HTTPS listener, NSG rule. Delete if HTTP only | Yes |
| [dashboard.tf][edd] | CloudWatch dashboard: CPU, memory, and HTTP-related metrics | Yes |
| [role.tf][edr] | Application Role for container | Yes |
| [cicd.tf][edc] | IAM user that can be used by CI/CD systems | Yes |
| [autoscale-perf.tf][edap] | Performance-based auto scaling | Yes |
| [autoscale-time.tf][edat] | Time-based auto scaling | Yes |
| [logs-logzio.tf][edll] | Ship container logs to logz.io | Yes |


## Usage

```
# Sets up Terraform to run
$ terraform init

# Executes the Terraform run
$ terraform apply
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app | The application's name | string | - | yes |
| aws_profile | The AWS Profile to use | string | - | yes |
| certificate_arn | The ARN for the SSL certificate | string | - | yes |
| container_name | The name of the container to run | string | `app` | no |
| container_port | The port the container will listen on, used for load balancer health check Best practice is that this value is higher than 1024 so the container processes isn't running at root. | string | - | yes |
| default_backend_image | The default docker image to deploy with the infrastructure. Note that you can use the fargate CLI for application concerns like deploying actual application images and environment variables on top of the infrastructure provisioned by this template https://github.com/turnerlabs/fargate note that the source for the turner default backend image is here: https://github.com/turnerlabs/turner-defaultbackend | string | `quay.io/turner/turner-defaultbackend:0.2.0` | no |
| deregistration_delay | The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused | string | `30` | no |
| ecs_as_cpu_high_threshold_per | If the average CPU utilization over a minute rises to this threshold, the number of containers will be increased (but not above ecs_autoscale_max_instances). | string | `80` | no |
| ecs_as_cpu_low_threshold_per | If the average CPU utilization over a minute drops to this threshold, the number of containers will be reduced (but not below ecs_autoscale_min_instances). | string | `20` | no |
| ecs_autoscale_max_instances | The maximum number of containers that should be running. | string | `8` | no |
| ecs_autoscale_min_instances | The minimum number of containers that should be running. Must be at least 1. For production, consider using at least "2". | string | `1` | no |
| environment | The environment that is being built | string | - | yes |
| health_check | The path to the health check for the load balancer to know if the container(s) are ready | string | - | yes |
| health_check_interval | How often to check the liveliness of the container | string | `30` | no |
| health_check_matcher | What HTTP response code to listen for | string | `200` | no |
| health_check_timeout | How long to wait for the response on the health check path | string | `10` | no |
| https_port | The port to listen on for HTTPS, always use 443 | string | `443` | no |
| internal | Whether the application is available on the public internet, also will determine which subnets will be used (public or private) | string | `true` | no |
| lb_port | The port the load balancer will listen on | string | `80` | no |
| lb_protocol | The load balancer protocol | string | `HTTP` | no |
| logz_token | The auth token to use for sending logs to Logz.io | string | - | yes |
| logz_url | The endpoint to use for sending logs to Logz.io | string | `https://listener.logz.io:8071` | no |
| private_subnets | The private subnets, minimum of 2, that are a part of the VPC(s) | string | - | yes |
| public_subnets | The public subnets, minimum of 2, that are a part of the VPC(s) | string | - | yes |
| region | The AWS region to use for the dev environment's infrastructure Currently, Fargate is only available in `us-east-1`. | string | `us-east-1` | no |
| replicas | How many containers to run | string | `1` | no |
| saml_role | The SAML role to use | string | - | yes |
| scale_down_count | The number of containers to scale down to | string | `0` | no |
| scale_down_cron | Default scale down at 7 pm every day | string | `cron(0 23 * * ? *)` | no |
| scale_up_count | The number of containers to scale up to | string | `1` | no |
| scale_up_cron | Default scale up at 7 am weekdays, this is UTC so it doesn't adjust to daylight savings https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html | string | `cron(0 11 ? * MON-FRI *)` | no |
| slack_webhook | An endpoint that will receive scale up/down notifications | string | `` | no |
| tags | Tags for the infrastructure | map | - | yes |
| vpc | The VPC to use for the Fargate cluster | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws_profile | Command to set the AWS_PROFILE |
| cicd_keys | The AWS keys for the CICD user to use in a build system |
| deploy | Command to deploy a new task definition to the service using Docker Compose |
| docker_registry | The URL for the docker image repo in ECR |
| lb_dns | The load balancer DNS name |
| scale_out | Command to scale out the number of tasks (container replicas) |
| scale_up | Command to scale up cpu and memory |
| status | Command to view the status of the Fargate service |



[edm]: main.tf
[ede]: ecs.tf
[edl]: lb.tf
[edn]: nsg.tf
[edlhttp]: lb-http.tf
[edlhttps]: lb-https.tf
[edd]: dashboard.tf
[edr]: role.tf
[edc]: cicd.tf
[edap]: autoscale-perf.tf
[edat]: autoscale-time.tf
[edll]: logs-logzio.tf
[alb-docs]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html
[up]: https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
