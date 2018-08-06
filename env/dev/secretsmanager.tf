# create the secretsmanager secret
resource "aws_secretsmanager_secret" "sm_secret" {
  name = "${var.app}-${var.environment}"
  tags = "${var.tags}"
  policy = "${data.aws_iam_policy_document.sm_resource_policy_doc.json}"
}

# get the saml user info so we can get the unique_id
data "aws_iam_role" "saml_role" {
  name = "${var.saml_role}"
}

# resource policy doc that limits access to secret
data "aws_iam_policy_document" "sm_resource_policy_doc" {
  statement = {
    sid = "DenyWriteToAllExceptSAMLUsers"
    effect = "Deny"
    principals = {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
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
    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-*"
    ]
    condition = {
      test = "StringNotLike"
      variable = "aws:userId"
      values = [
        "${data.aws_caller_identity.current.user_id}",
        "${data.aws_caller_identity.current.account_id}",
        "${formatlist("%s:%s", data.aws_iam_role.saml_role.unique_id, var.saml_users)}"
      ]
    }
  }

  statement = {
    sid = "DenyReadToAllExceptSAMLandApp"
    effect = "Deny"
    principals = {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:List*",
      "secretsmanager:GetRandomPassword",
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-*"
    ]
    condition = {
      test = "StringNotLike"
      variable = "aws:userId"
      values = [
        "${aws_iam_role.app_role.unique_id}:*",
        "${data.aws_caller_identity.current.user_id}",
        "${data.aws_caller_identity.current.account_id}",
        "${formatlist("%s:%s", data.aws_iam_role.saml_role.unique_id, var.saml_users)}"
      ]
    }
  }

  statement = {
    sid = "AllowWriteToSAMLUsers"
    effect = "Allow"
    principals = {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
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
    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-*"
    ]
    condition = {
      test = "StringLike"
      variable = "aws:userId"
      values = [
        "${data.aws_caller_identity.current.user_id}",
        "${data.aws_caller_identity.current.account_id}",
        "${formatlist("%s:%s", data.aws_iam_role.saml_role.unique_id, var.saml_users)}"
      ]
    }
  }

  statement = {
    sid = "AllowWriteSAMLUsersAndRole"
    effect = "Allow"
    principals = {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:List*",
      "secretsmanager:GetRandomPassword",
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-*"
    ]
    condition = {
      test = "StringLike"
      variable = "aws:userId"
      values = [
        "${aws_iam_role.app_role.unique_id}:*",
        "${data.aws_caller_identity.current.user_id}",
        "${data.aws_caller_identity.current.account_id}",
        "${formatlist("%s:%s", data.aws_iam_role.saml_role.unique_id, var.saml_users)}"
      ]
    }
  }
}

# secretsmanager assumabale roles and policies
data "aws_iam_policy_document" "sm_app_policy_doc" {
  statement = {
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetRandomPassword",
      "secretsmanager:GetSecretValue",
      "secretsmanager:List*",
    ]

    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-*",
    ]
  }
}

resource "aws_iam_role_policy" "sm_app_policy" {
  name   = "sm_role_policy"
  role   = "${aws_iam_role.app_role.name}"
  policy = "${data.aws_iam_policy_document.sm_app_policy_doc.json}"
}

# The users from the saml role to give access

variable "saml_users" {
  type = "list"
}
