/**
 * This module posts to an SNS topic when the app becomes unhealthy.
 * You can provide your own SNS topic by supplying the variable:
 * monitoring_sns_topic = "my-topic"
 *
 */

# The name of an SNS topic that alarms post to
variable "monitoring_sns_topic" {
  type        = string
  default     = "BigPanda_Topic"
  description = "The name of an SNS topic that alarms post to"
}

# looks up the sns topic used for monitoring
data "aws_sns_topic" "monitoring" {
  name = var.monitoring_sns_topic
}

# posts to an sns topic when HealthyHostCount gets too low
resource "aws_cloudwatch_metric_alarm" "healthyhost_alarm" {
  alarm_name        = "${var.app}-${var.environment}-healthyhost-alarm"
  alarm_description = "posts to an sns topic when HealthyHostCount gets too low"
  metric_name       = "HealthyHostCount"
  namespace         = "AWS/ApplicationELB"
  dimensions = {
    LoadBalancer = aws_alb.main.arn_suffix
    TargetGroup  = aws_alb_target_group.main.arn_suffix
  }
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = "300"
  statistic           = "Average"
  threshold           = "0.8"
  treat_missing_data  = "breaching"
  alarm_actions       = [data.aws_sns_topic.monitoring.arn]
  ok_actions          = [data.aws_sns_topic.monitoring.arn]
}

# posts to an sns topic when there are 50 HTTPCode_Target_5XX_Count in 5 minutes
resource "aws_cloudwatch_metric_alarm" "target_5xx_alarm" {
  alarm_name        = "${var.app}-${var.environment}-target-5xx-alarm"
  alarm_description = "posts to an sns topic when there are 50 HTTPCode_Target_5XX_Count in 5 minutes"
  metric_name       = "HTTPCode_Target_5XX_Count"
  namespace         = "AWS/ApplicationELB"
  dimensions = {
    LoadBalancer = aws_alb.main.arn_suffix
    TargetGroup  = aws_alb_target_group.main.arn_suffix
  }
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = "300"
  statistic           = "Sum"
  threshold           = "50"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [data.aws_sns_topic.monitoring.arn]
  ok_actions          = [data.aws_sns_topic.monitoring.arn]
}

# posts to an sns topic when there are 50 HTTPCode_ELB_5XXs in 5 minutes
resource "aws_cloudwatch_metric_alarm" "lb_5xx_alarm" {
  alarm_name        = "${var.app}-${var.environment}-lb-5xx-alarm"
  alarm_description = "posts to an sns topic when there are 50 HTTPCode_ELB_5XXs in 5 minutes"
  metric_name       = "HTTPCode_ELB_5XX"
  namespace         = "AWS/ApplicationELB"
  dimensions = {
    LoadBalancer = aws_alb.main.arn_suffix
    TargetGroup  = aws_alb_target_group.main.arn_suffix
  }
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = "300"
  statistic           = "Sum"
  threshold           = "50"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [data.aws_sns_topic.monitoring.arn]
  ok_actions          = [data.aws_sns_topic.monitoring.arn]
}