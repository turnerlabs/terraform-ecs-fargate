/**
 * This module sets up time-based autoscaling.
 * This could be used to turn off a service durning non-business hours.
 */

# Default scale up at 7 am weekdays, this is UTC so it doesn't adjust to daylight savings
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "scale_up_cron" {
  default = "cron(0 11 ? * MON-FRI *)"
}

# Default scale down at 7 pm every day
variable "scale_down_cron" {
  default = "cron(0 23 * * ? *)"
}

# The mimimum number of containers to scale down to.
# Set this and `scale_down_max_capacity` to 0 to turn off service on the `scale_down_cron` schedule.
variable "scale_down_min_capacity" {
  default = 0
}

# The maximum number of containers to scale down to.
variable "scale_down_max_capacity" {
  default = 0
}

# Scales service back up to preferred running capacity defined by the
# `ecs_autoscale_min_instances` and `ecs_autoscale_max_instances` variables
resource "aws_appautoscaling_scheduled_action" "app_autoscale_time_up" {
  name = "app-autoscale-time-up-${var.app}-${var.environment}"

  service_namespace  = "${aws_appautoscaling_target.app_scale_target.service_namespace}"
  resource_id        = "${aws_appautoscaling_target.app_scale_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.app_scale_target.scalable_dimension}"
  schedule           = "${var.scale_up_cron}"

  scalable_target_action {
    min_capacity = "${aws_appautoscaling_target.app_scale_target.min_capacity}"
    max_capacity = "${aws_appautoscaling_target.app_scale_target.max_capacity}"
  }
}

# Scales service down to capacity defined by the
# `scale_down_min_capacity` and `scale_down_max_capacity` variables.
resource "aws_appautoscaling_scheduled_action" "app_autoscale_time_down" {
  name = "app-autoscale-time-down-${var.app}-${var.environment}"

  service_namespace  = "${aws_appautoscaling_target.app_scale_target.service_namespace}"
  resource_id        = "${aws_appautoscaling_target.app_scale_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.app_scale_target.scalable_dimension}"
  schedule           = "${var.scale_down_cron}"

  scalable_target_action {
    min_capacity = "${var.scale_down_min_capacity}"
    max_capacity = "${var.scale_down_max_capacity}"
  }
}
