# create the secretsmanager secret
resource "aws_secretsmanager_secret" "sm_secret" {
  name = "${var.app}-${var.environment}"
  tags = "${var.tags}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyWriteToAllExceptSAMLUsers",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [
        "secretsmanager:CancelRotateSecret",
        "secretsmanager:CreateSecret",
        "secretsmanager:DeleteResourcePolicy",
        "secretsmanager:DeleteSecret",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:PutResourcePolicy",
        "secretsmanager:PutSecretValue",
        "secretsmanager:RestoreSecret",
        "secretsmanager:RotateSecret",
        "secretsmanager:TagResource",
        "secretsmanager:UntagResource",
        "secretsmanager:UpdateSecret",
        "secretsmanager:UpdateSecretVersionStage"
      ],
      "Resource": [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-*"
      ],
      "Condition": {
        "StringNotLike": {
          "aws:arn": [
            "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.saml_role}/me@example.com"
          ]
        }
      }
    },
    {
      "Sid": "DenyReadToAllExceptSAMLandApp",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetRandomPassword",
        "secretsmanager:GetSecretValue",
        "secretsmanager:List*"
      ],
      "Resource": [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-*"
      ],
      "Condition": {
        "StringNotLike": {
          "aws:arn": [
            "${aws_iam_role.app_role.arn}",
            "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.saml_role}/me@example.com"
          ]
        }
      }
    }
  ]
}
EOF
}

# secretsmanager assumabale roles and policies
data "aws_iam_policy_document" "sm_policy_doc" {
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

resource "aws_iam_role_policy" "sm_policy" {
  name   = "sm_role_policy"
  role   = "${aws_iam_role.app_role.name}"
  policy = "${data.aws_iam_policy_document.sm_policy_doc.json}"
}
