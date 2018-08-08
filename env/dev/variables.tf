/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

 # The AWS region to use for the dev environment's infrastructure
 # Currently, Fargate is only available in `us-east-1`.
variable "region" {
  default = "us-east-1"
}

# The AWS Profile to use
variable "aws_profile" {}

# The SAML role to use
variable "saml_role" {}

# Tags for the infrastructure
variable "tags" {
  type = "map"
}

# The application's name
variable "app" {}

# The environment that is being built
variable "environment" {}

# Whether the application is available on the public internet,
# also will determine which subnets will be used (public or private)
variable "internal" {
  default = "true"
}

# The port the container will listen on, used for load balancer health check
# Best practice is that this value is higher than 1024 so the container processes
# isn't running at root.
variable "container_port" {}

# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "HTTP"
}

# How many containers to run
variable "replicas" {
  default = "1"
}

# The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused
variable "deregistration_delay" {
  default = "30"
}

# The path to the health check for the load balancer to know if the container(s) are ready
variable "health_check" {}

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

# The name of the container to run
variable "container_name" {}

# Network configuration

# The VPC to use for the Fargate cluster
variable "vpc" {}

# The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets" {}

# The public subnets, minimum of 2, that are a part of the VPC(s)
variable "public_subnets" {}
