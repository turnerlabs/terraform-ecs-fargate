# The auth token to use for sending logs to Logz.io
variable "logz_token" {
}

# The endpoint to use for sending logs to Logz.io
variable "logz_url" {
  default = "https://listener.logz.io:8071"
}

resource "aws_iam_role" "iam_for_lambda_logz" {
  name = "${var.app}-${var.environment}-logz-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "lambda_policy_logs_logz" {
  name = "${var.app}-${var.environment}-logz-role"
  role = aws_iam_role.iam_for_lambda_logz.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

}

#function code from logzio: https://github.com/logzio/cloudwatch-logs-shipper-lambda
resource "aws_lambda_function" "lambda_logz" {
  function_name    = "${var.app}-${var.environment}-logz"
  description      = "Sends Cloudwatch logs to logz."
  runtime          = "python2.7"
  timeout          = 60
  memory_size      = 512
  role             = aws_iam_role.iam_for_lambda_logz.arn
  handler          = "lambda_function.lambda_handler"
  filename         = "logs-logzio.zip"
  source_code_hash = filebase64sha256("logs-logzio.zip")

  tags = var.tags

  environment {
    variables = {
      TOKEN = var.logz_token
      URL   = var.logz_url
      TYPE  = "elb"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "${var.app}-${var.environment}-logz"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_logz.arn
  principal     = "logs.${var.region}.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.logs.arn
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_lambda_subscription" {
  depends_on      = [aws_lambda_permission.allow_cloudwatch]
  name            = "${var.app}-${var.environment}-logz"
  log_group_name  = aws_cloudwatch_log_group.logs.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_logz.arn
}
