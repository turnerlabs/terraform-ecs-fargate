# The application's name
variable "app" {
    type=string
}

# The environment that is being built
variable "environment" {
    type=string
}

# Should the module create an iam user with permissions tuned for cicd (cicf.tf)
variable "create_cicd_user" {
    type = bool
    default = false
}

# Tags for the infrastructure
variable "tags" {
  type = map(string)
}

# The port the container will listen on, used for load balancer health check
# Best practice is that this value is higher than 1024 so the container processes
# isn't running at root.
variable "container_port" {
    type = string
}

# The VPC to use for the Fargate cluster
variable "vpc" {
}

# The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets" {
}

# The public subnets, minimum of 2, that are a part of the VPC(s)
variable "public_subnets" {
}

# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "HTTP"
}

# Whether the application is available on the public internet,
# also will determine which subnets will be used (public or private)
variable "internal" {
  default = true
}

# The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused
variable "deregistration_delay" {
  default = "30"
}

# The path to the health check for the load balancer to know if the container(s) are ready
variable "health_check" {
    default = "/"
}

# How often to check the liveliness of the container
variable "health_check_interval" {
  default = "30"
}

# How long to wait for the response on the health check path
variable "health_check_timeout" {
  default = "10"
}

# What HTTP response code to listen for
variable "health_check_matcher" {
  default = "200"
}

variable "lb_access_logs_expiration_days" {
  default = "3"
}

# Create a cloudwatch dashboard containing popular performance metrics about fargate
variable "create_performance_dashboard" {
    type = bool
    default = true
}

# Log the ECS events happening in fargate and create a cloudwatch dashboard that shows these messages
variable "create_ecs_dashboard" {
    type = bool
    default = false
}

# The lambda runtime for the ecs dashboard, provided here so that it is easy to update to the latest supported
variable "ecs_lambda_runtime" {
    type = string
    default = "nodejs14.x"
}

# The port to listen on for HTTPS, always use 443
variable "https_port" {
  default = "443"
}

# The ARN for the SSL certificate
variable "certificate_arn" {
  default = ""
}

# The domain for r53 registration
variable "domain" {
  default = ""
}

#indicates if a secrets manager 
variable "secrets_manager" {
  type = bool
  default = false
}

# Number of days that secrets manager will wait before fully deleting a secret, set to 0 to delete immediately
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#recovery_window_in_days
variable "secrets_manager_recovery_window_in_days" {
  type = number
  default = 7
}

#take this out
variable "saml_role" {
  type = string
}