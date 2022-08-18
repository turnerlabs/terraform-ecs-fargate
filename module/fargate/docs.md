## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | The application's name | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port the container will listen on, used for load balancer health check Best practice is that this value is higher than 1024 so the container processes isn't running at root. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment that is being built | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | The private subnets, minimum of 2, that are a part of the VPC(s) | `any` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | The public subnets, minimum of 2, that are a part of the VPC(s) | `any` | n/a | yes |
| <a name="input_saml_role"></a> [saml\_role](#input\_saml\_role) | take this out | `string` | n/a | yes |
| <a name="input_secrets_saml_users"></a> [secrets\_saml\_users](#input\_secrets\_saml\_users) | The users (email addresses) from the saml role to give access | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the infrastructure | `map(string)` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The VPC to use for the Fargate cluster | `any` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The ARN for the SSL certificate, if this is not blank it will use it instead of requesting a dns validated ACM certificate | `string` | `""` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | The default docker image to deploy with the infrastructure. Note that you can use the fargate CLI for application concerns like deploying actual application images and environment variables on top of the infrastructure provisioned by this template https://github.com/turnerlabs/fargate note that the source for the turner default backend image is here: https://github.com/turnerlabs/turner-defaultbackend | `string` | `"quay.io/turner/turner-defaultbackend:0.2.0"` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the container to run | `string` | `"app"` | no |
| <a name="input_cpu_units"></a> [cpu\_units](#input\_cpu\_units) | See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size | `number` | `256` | no |
| <a name="input_create_cicd_user"></a> [create\_cicd\_user](#input\_create\_cicd\_user) | Should the module create an iam user with permissions tuned for cicd (cicf.tf) | `bool` | `false` | no |
| <a name="input_create_ecs_dashboard"></a> [create\_ecs\_dashboard](#input\_create\_ecs\_dashboard) | Log the ECS events happening in fargate and create a cloudwatch dashboard that shows these messages | `bool` | `false` | no |
| <a name="input_create_performance_dashboard"></a> [create\_performance\_dashboard](#input\_create\_performance\_dashboard) | Create a cloudwatch dashboard containing popular performance metrics about fargate | `bool` | `true` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused | `string` | `"30"` | no |
| <a name="input_do_https_redirect"></a> [do\_https\_redirect](#input\_do\_https\_redirect) | Should the service do http to https redirects, or just standard http hosting? This is done via alb rules https://aws.amazon.com/premiumsupport/knowledge-center/elb-redirect-http-to-https-using-alb/ | `bool` | `false` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain for r53 registration, leave blank to indicate not using route53 | `string` | `""` | no |
| <a name="input_ecs_autoscale_max_instances"></a> [ecs\_autoscale\_max\_instances](#input\_ecs\_autoscale\_max\_instances) | The maximum number of containers that should be running. used by both autoscale-perf.tf and autoscale.time.tf | `string` | `"8"` | no |
| <a name="input_ecs_autoscale_min_instances"></a> [ecs\_autoscale\_min\_instances](#input\_ecs\_autoscale\_min\_instances) | The minimum number of containers that should be running. Must be at least 1. used by both autoscale-perf.tf and autoscale.time.tf For production, consider using at least "2". | `string` | `"1"` | no |
| <a name="input_ecs_lambda_runtime"></a> [ecs\_lambda\_runtime](#input\_ecs\_lambda\_runtime) | The lambda runtime for the ecs dashboard, provided here so that it is easy to update to the latest supported | `string` | `"nodejs14.x"` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | The path to the health check for the load balancer to know if the container(s) are ready | `string` | `"/"` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | How often to check the liveliness of the container | `string` | `"30"` | no |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | What HTTP response code to listen for | `string` | `"200"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | How long to wait for the response on the health check path | `string` | `"10"` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | The port to listen on for HTTPS (if it is enabled), always use 443 | `string` | `"443"` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Whether the application is available on the public internet, also will determine which subnets will be used (public or private) | `bool` | `true` | no |
| <a name="input_lb_access_logs_expiration_days"></a> [lb\_access\_logs\_expiration\_days](#input\_lb\_access\_logs\_expiration\_days) | How many days worth of load balancer logs to keep in s3 | `string` | `"3"` | no |
| <a name="input_lb_port"></a> [lb\_port](#input\_lb\_port) | The port the standard http load balancer will listen on | `string` | `"80"` | no |
| <a name="input_lb_protocol"></a> [lb\_protocol](#input\_lb\_protocol) | The load balancer protocol | `string` | `"HTTP"` | no |
| <a name="input_logs_retention_in_days"></a> [logs\_retention\_in\_days](#input\_logs\_retention\_in\_days) | Specifies the number of days you want to retain log events | `number` | `90` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size | `number` | `512` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | How many containers to run | `number` | `1` | no |
| <a name="input_secrets_manager"></a> [secrets\_manager](#input\_secrets\_manager) | indicates if a secrets manager | `bool` | `false` | no |
| <a name="input_secrets_manager_recovery_window_in_days"></a> [secrets\_manager\_recovery\_window\_in\_days](#input\_secrets\_manager\_recovery\_window\_in\_days) | Number of days that secrets manager will wait before fully deleting a secret, set to 0 to delete immediately https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#recovery_window_in_days | `number` | `7` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cicd_keys"></a> [cicd\_keys](#output\_cicd\_keys) | The AWS keys for the CICD user to use in a build system |
| <a name="output_lb_dns"></a> [lb\_dns](#output\_lb\_dns) | The load balancer DNS name |
| <a name="output_subdomain"></a> [subdomain](#output\_subdomain) | n/a |
