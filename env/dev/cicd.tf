# create ci/cd user with access keys (for build system)
resource "aws_iam_user" "cicd" {
  name = "srv_${var.app}_${var.environment}_cicd"
}

resource "aws_iam_access_key" "cicd_keys" {
  user = "${aws_iam_user.cicd.name}"
}

# grant required permissions to deploy
data "aws_iam_policy_document" "cicd_policy" {
  # allows user to push/pull to the registry
  statement {
    sid = "ecr"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]

    resources = [
      "${data.aws_ecr_repository.ecr.arn}",
    ]
  }

  # allows user to deploy to ecs
  statement {
    sid = "ecs"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:UpdateService",
      "ecs:RegisterTaskDefinition",
    ]

    resources = [
      "*",
    ]
  }

  # allows user to run ecs task using task execution and app roles
  statement {
    sid = "approle"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "${aws_iam_role.app_role.arn}",
      "${aws_iam_role.ecsTaskExecutionRole.arn}",
    ]
  }
}

resource "aws_iam_user_policy" "cicd_user_policy" {
  name   = "${var.app}_${var.environment}_cicd"
  user   = "${aws_iam_user.cicd.name}"
  policy = "${data.aws_iam_policy_document.cicd_policy.json}"
}

data "aws_ecr_repository" "ecr" {
  name = "${var.app}"
}

# The AWS keys for the CICD user to use in a build system
output "cicd_keys" {
  value = "terraform state show aws_iam_access_key.cicd_keys"
}

# The URL for the docker image repo in ECR
output "docker_registry" {
  value = "${data.aws_ecr_repository.ecr.repository_url}"
}