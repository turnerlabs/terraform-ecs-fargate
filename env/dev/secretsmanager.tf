# create the secretsmanager secret
resource "aws_secretsmanager_secret" "sm_secret" {
  name = "${var.app}-${var.environment}"
  tags = "${var.tags}"
}

# secretsmanager assumabale roles and policies
data "aws_iam_policy_document" "sm_policy_doc" {
  statement = {
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:Get*",
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

# create the script to load the secrets into the secretsmanager secret
data "template_file" "load_secrets_tpl" {
  template = "${file("${path.module}/load-secrets.tpl")}"

  vars {
    region      = "${var.region}"
    aws_profile = "${var.aws_profile}"
    secret      = "${var.app}-${var.environment}"
  }
}

resource "local_file" "load_secrets" {
  filename = "upload-secrets.sh"
  content  = "${data.template_file.load_secrets_tpl.rendered}"
}
