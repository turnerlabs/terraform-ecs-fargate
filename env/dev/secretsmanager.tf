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
        "secretsmanager:DeleteSecret",
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
          "aws:userId": [
            "${data.aws_iam_role.saml_role.unique_id}:me@example.com",
            "${data.aws_caller_identity.current.account_id}"
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
        "secretsmanager:List*",
        "secretsmanager:GetRandomPassword",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-*"
      ],
      "Condition": {
        "StringNotLike": {
          "aws:userId": [
            "${aws_iam_role.app_role.unique_id}:*",
            "${data.aws_iam_role.saml_role.unique_id}:me@example.com",
            "${data.aws_caller_identity.current.account_id}"
          ]
        }
      }
    },
    {
      "Sid": "AllowWriteToSAMLUsers",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "secretsmanager:CancelRotateSecret",
        "secretsmanager:CreateSecret",
        "secretsmanager:DeleteResourcePolicy",
        "secretsmanager:DeleteSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:RestoreSecret",
        "secretsmanager:RotateSecret",
        "secretsmanager:TagResource",
        "secretsmanager:UntagResource",
        "secretsmanager:UpdateSecret",
        "secretsmanager:UpdateSecretVersionStage"
      ],
      "Resource": [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-??????"
      ],
      "Condition": {
        "StringLike": {
          "aws:userId": [
            "${data.aws_iam_role.saml_role.unique_id}:me@example.com",
            "${data.aws_caller_identity.current.account_id}"
          ]
        }
      }
    },
    {
      "Sid": "allowWriteSAMLUsersAndRole",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:List*",
        "secretsmanager:GetRandomPassword",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app}-${var.environment}-*"
      ],
      "Condition": {
        "StringLike": {
          "aws:userId": [
            "${aws_iam_role.app_role.unique_id}:*",
            "${data.aws_iam_role.saml_role.unique_id}:me@example.com",
            "${data.aws_caller_identity.current.account_id}"
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
