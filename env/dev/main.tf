terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 5.0.0"
    }
  }

  backend "s3" {
    region  = "us-east-1"
    profile = ""
    bucket  = ""
    key     = "dev.terraform.tfstate"
  }
}

# The AWS Profile to use
variable "aws_profile" {
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# output

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
  value = var.aws_profile
}
