/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the bucket and registry
variable "region" {
  default = "us-east-1"
}

# The AWS profile to use, this would be the same value used in AWS_PROFILE.
variable "aws_profile" {
}

# The role that will have access to the S3 bucket, this should be a role that all
# members of the team have access to.
variable "saml_role" {
}

# Name of the application. This value should usually match the application tag below.
variable "app" {
}

# A map of the tags to apply to various resources. The required tags are:
# `application`, name of the app;
# `environment`, the environment being created;
# `team`, team responsible for the application;
# `contact-email`, contact email for the _team_;
# and `customer`, who the application was create for.
variable "tags" {
  type = map(string)
}
