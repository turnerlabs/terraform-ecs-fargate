# create the secretsmanager secret
resource "aws_secretsmanager_secret" "sm_secret" {
  name   = "${var.app}-${var.environment}"
  tags   = "${var.tags}"
  policy = "${data.aws_iam_policy_document.sm_resource_policy_doc.json}"
}

# get the saml user info so we can get the unique_id
data "aws_iam_role" "saml_role" {
  name = "${var.saml_role}"
}

# Allow for code reuse...
locals {
  # secretsmanager write actions
  sm_write_actions = [
    "secretsmanager:CancelRotateSecret",
    "secretsmanager:CreateSecret",
    "secretsmanager:DeleteSecret",
    "secretsmanager:PutSecretValue",
    "secretsmanager:RestoreSecret",
    "secretsmanager:RotateSecret",
    "secretsmanager:TagResource",
    "secretsmanager:UntagResource",
    "secretsmanager:UpdateSecret",
    "secretsmanager:UpdateSecretVersionStage",
  ]

  # secretsmanager read actions
  sm_read_actions = [
    "secretsmanager:DescribeSecret",
    "secretsmanager:List*",
    "secretsmanager:GetRandomPassword",
    "secretsmanager:GetSecretValue",
  ]

  # list of saml users for policies
  saml_user_ids = [
    "${data.aws_caller_identity.current.user_id}",
    "${data.aws_caller_identity.current.account_id}",
    "${formatlist("%s:%s", data.aws_iam_role.saml_role.unique_id, var.secrets_saml_users)}",
  ]

  # list of role users and saml users for policies
  role_and_saml_ids = [
    "${aws_iam_role.app_role.unique_id}:*",
    "${local.saml_user_ids}",
  ]

  sm_arn = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-??????"
}

# resource policy doc that limits access to secret
data "aws_iam_policy_document" "sm_resource_policy_doc" {
  statement = {
    sid    = "DenyWriteToAllExceptSAMLUsers"
    effect = "Deny"

    principals = {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["${local.sm_write_actions}"]
    resources = ["${local.sm_arn}"]

    condition = {
      test     = "StringNotLike"
      variable = "aws:userId"
      values   = ["${local.saml_user_ids}"]
    }
  }

  statement = {
    sid    = "DenyReadToAllExceptRoleAndSAMLUsers"
    effect = "Deny"

    principals = {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["${local.sm_read_actions}"]
    resources = ["${local.sm_arn}"]

    condition = {
      test     = "StringNotLike"
      variable = "aws:userId"
      values   = ["${local.role_and_saml_ids}"]
    }
  }

  statement = {
    sid    = "AllowWriteToSAMLUsers"
    effect = "Allow"

    principals = {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["${local.sm_write_actions}"]
    resources = ["${local.sm_arn}"]

    condition = {
      test     = "StringLike"
      variable = "aws:userId"
      values   = ["${local.saml_user_ids}"]
    }
  }

  statement = {
    sid    = "AllowReadRoleAndSAMLUsers"
    effect = "Allow"

    principals = {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["${local.sm_read_actions}"]
    resources = ["${local.sm_arn}"]

    condition = {
      test     = "StringLike"
      variable = "aws:userId"
      values   = ["${local.role_and_saml_ids}"]
    }
  }
}

# The users from the saml role to give access

variable "secrets_saml_users" {
  type = "list"
}
