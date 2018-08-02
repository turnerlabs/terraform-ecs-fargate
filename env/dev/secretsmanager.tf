# create the secretsmanager secret
resource "aws_secretsmanager_secret" "sm_secret" {
  name = "${var.app}-${var.environment}"
  tags = "${var.tags}"
  policy = "${data.aws_iam_policy_document.sm_resource_policy_doc.json}"
}

data "aws_iam_role" "saml_role" {
  name = "${var.saml_role}"
}

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
        "${data.aws_iam_role.saml_role.unique_id}:James.Hodnett@turner.com",
        "${data.aws_caller_identity.current.account_id}",
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
        "${data.aws_iam_role.saml_role.unique_id}:James.Hodnett@turner.com",
        "${data.aws_caller_identity.current.account_id}",
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
        "${data.aws_iam_role.saml_role.unique_id}:James.Hodnett@turner.com",
        "${data.aws_caller_identity.current.account_id}",
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
        "${data.aws_iam_role.saml_role.unique_id}:James.Hodnett@turner.com",
        "${data.aws_caller_identity.current.account_id}",
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

# create the script to load the secrets into the secretsmanager secret
data "template_file" "upload_secrets_tpl" {
  template = "${file("${path.module}/upload-secrets.tpl")}"

  vars {
    region      = "${var.region}"
    aws_profile = "${var.aws_profile}"
    secret      = "${var.app}-${var.environment}"
  }
}

resource "local_file" "load_secrets" {
  filename = "upload-secrets.sh"
  content  = "${data.template_file.upload_secrets_tpl.rendered}"
}
