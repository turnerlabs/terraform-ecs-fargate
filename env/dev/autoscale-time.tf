/**
 * Will create a lambda that will scale the service to specified values at predetermined times.
 * This could be used to turn off a service durning non-business hours,
 * or to just lower/increase it based on known timelines
 * The source code for this lambda function can be found https://github.com/turnerlabs/fargate-autoscale-time
 */

# The number of containers to scale up to
variable "scale_up_count" {
  default = "1"
}

# The number of containers to scale down to
variable "scale_down_count" {
  default = "0"
}

# Default scale up at 7 am weekdays, this is UTC so it doesn't adjust to daylight savings
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "scale_up_cron" {
  default = "cron(0 11 ? * MON-FRI *)"
}

# Default scale down at 7 pm every day
variable "scale_down_cron" {
  default = "cron(0 23 * * ? *)"
}

# An endpoint that will receive scale up/down notifications
variable "slack_webhook" {
  default = ""
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.app}-${var.environment}-lambdarole"

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

resource "aws_iam_role_policy" "lambda_policy_logs" {
  name = "${var.app}-${var.environment}-lambdapolicy"
  role = "${aws_iam_role.iam_for_lambda.id}"

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
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService"
      ],
      "Resource": [
        "*"
      ]
    }

  ]
}
EOF
}

resource "aws_lambda_function" "lambda_scaledown" {
  function_name    = "${var.app}-${var.environment}-fargate-scale-down"
  description      = "Scales down a Fargate service"
  runtime          = "nodejs6.10"
  timeout          = 30
  memory_size      = 128
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "scale.handler"
  filename         = "autoscale-time.zip"
  source_code_hash = "${base64sha256(file("autoscale-time.zip"))}"

  tags = "${var.tags}"

  environment {
    variables = {
      scale_to      = "${var.scale_down_count}"
      cluster       = "${aws_ecs_cluster.app.name}"
      service       = "${aws_ecs_service.app.name}"
      slack_webhook = "${var.slack_webhook}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "lambdascaledown_schedule" {
  name                = "${var.app}-${var.environment}-fargate-scale-down"
  description         = "Calls lambda on a schedule"
  schedule_expression = "${var.scale_down_cron}"
}

resource "aws_cloudwatch_event_target" "call_lambdascaledown_schedule" {
  rule = "${aws_cloudwatch_event_rule.lambdascaledown_schedule.name}"
  arn  = "${aws_lambda_function.lambda_scaledown.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_scaledown" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_scaledown.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambdascaledown_schedule.arn}"
}

resource "aws_lambda_function" "lambda_scaleup" {
  function_name    = "${var.app}-${var.environment}-fargate-scale-up"
  description      = "Scales up a Fargate service"
  runtime          = "nodejs6.10"
  timeout          = 30
  memory_size      = 128
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "scale.handler"
  filename         = "autoscale-time.zip"
  source_code_hash = "${base64sha256(file("autoscale-time.zip"))}"

  tags = "${var.tags}"

  environment {
    variables = {
      scale_to      = "${var.scale_up_count}"
      cluster       = "${aws_ecs_cluster.app.name}"
      service       = "${aws_ecs_service.app.name}"
      slack_webhook = "${var.slack_webhook}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "lambdascaleup_schedule" {
  name                = "${var.app}-${var.environment}-fargate-scale-up"
  description         = "Calls lambda on a schedule"
  schedule_expression = "${var.scale_up_cron}"
}

resource "aws_cloudwatch_event_target" "call_scaleup_schedule" {
  rule = "${aws_cloudwatch_event_rule.lambdascaleup_schedule.name}"
  arn  = "${aws_lambda_function.lambda_scaleup.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_scaleup" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_scaleup.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambdascaleup_schedule.arn}"
}
