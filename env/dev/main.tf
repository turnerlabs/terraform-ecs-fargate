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

# The URL for the docker image repo in ECR
output "docker_registry" {
  value = "${data.aws_ecr_repository.ecr.repository_url}"
}

# Command to view the status of the Fargate service
output "status" {
  value = "fargate service info"
}

# Command to deploy a new task definition to the service using Docker Compose
output "deploy" {
  value = "fargate service deploy -f docker-compose.yml"
}

# The AWS keys for the CICD user to use in a build system
output "cicd_keys" {
  value = "terraform state show aws_iam_access_key.cicd_keys"
}

# Command to set the AWS_PROFILE
output "aws_profile" {
  value = "${var.aws_profile}"
}
