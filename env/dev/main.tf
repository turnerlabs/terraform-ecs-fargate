terraform {
  backend "s3" {
    region  = "us-east-1"
    profile = ""
    bucket  = ""
    key     = "dev.terraform.tfstate"
  }
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.aws_profile}"
}

# output

# The load balancer DNS name
output "lb_dns" {
  value = "${aws_alb.main.dns_name}"
}

# Command to view the status of the Fargate service
output "status" {
  value = "fargate service info"
}

# Command to deploy a new task definition to the service using Docker Compose
output "deploy" {
  value = "fargate service deploy -f docker-compose.yml"
}

# Command to scale up cpu and memory
output "scale_up" {
  value = "fargate service update -h"
}

# Command to scale out the number of tasks (container replicas)
output "scale_out" {
  value = "fargate service scale -h"
}

# Command to set the AWS_PROFILE
output "aws_profile" {
  value = "${var.aws_profile}"
}
