/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

 # The AWS region to use for the dev environment's infrastructure
 # Currently, Fargate is only available in `us-east-1`.
variable "region" {
  default = "us-east-1"
}

# Tags for the infrastructure
variable "tags" {
  type = "map"
}

# The application's name
variable "app" {}

# The environment that is being built
variable "environment" {}

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

# Network configuration

# The VPC to use for the Fargate cluster
variable "vpc" {}

# The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets" {}

# The public subnets, minimum of 2, that are a part of the VPC(s)
variable "public_subnets" {}
