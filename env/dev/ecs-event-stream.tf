/**
 * ECS Event Stream
 * This component gives you full access to the ECS event logs
 * for your cluster by creating a cloudwatch event rule that listens for 
 * events for this cluster and calls a lambda that writes them to cloudwatch logs 
 * (which can be queried by other tools, like fargate cli).
 */

# cw event rule
resource "aws_cloudwatch_event_rule" "ecs_event_stream" {
  name        = "${var.app}-${var.environment}-ecs-event-stream"
  description = "Passes ecs event logs for ${var.app}-${var.environment} to a lambda that writes them to cw logs"

  event_pattern = <<PATTERN
  {
    "detail": {
      "clusterArn": ["${aws_ecs_cluster.app.arn}"]
    }
  }
  PATTERN
}

resource "aws_cloudwatch_event_target" "ecs_event_stream" {
  rule = "${aws_cloudwatch_event_rule.ecs_event_stream.name}"
  arn  = "${aws_lambda_function.ecs_event_stream.arn}"
}

data "template_file" "lambda_source" {
  template = <<EOF
exports.handler = (event, context, callback) => {
  console.log(JSON.stringify(event));
}
EOF
}

data "archive_file" "lambda_zip" {
  type                    = "zip"
  source_content          = "${data.template_file.lambda_source.rendered}"
  source_content_filename = "index.js"
  output_path             = "lambda-${var.app}.zip"
}

resource "aws_lambda_permission" "ecs_event_stream" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ecs_event_stream.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ecs_event_stream.arn}"
}

resource "aws_lambda_function" "ecs_event_stream" {
  function_name    = "${var.app}-${var.environment}-ecs-event-stream"
  role             = "${aws_iam_role.ecs_event_stream.arn}"
  filename         = "${data.archive_file.lambda_zip.output_path}"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  tags             = "${var.tags}"
}

resource "aws_lambda_alias" "ecs_event_stream" {
  name             = "${aws_lambda_function.ecs_event_stream.function_name}"
  description      = "latest"
  function_name    = "${aws_lambda_function.ecs_event_stream.function_name}"
  function_version = "$LATEST"
}

resource "aws_iam_role" "ecs_event_stream" {
  name = "${aws_cloudwatch_event_rule.ecs_event_stream.name}"

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

resource "aws_iam_role_policy_attachment" "ecs_event_stream" {
  role       = "${aws_iam_role.ecs_event_stream.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
