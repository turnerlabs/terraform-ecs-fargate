# note that this creates an nlb and target group
# the listeners are defined in lb-tcp.tf
# This is intented to be used instead of either
# lb-http.tf and/or lb-https.tf

resource "aws_lb" "main" {
  name               = "${var.app}-${var.environment}"
  load_balancer_type = "${var.lb_type}"

  # launch lbs in public or private subnets based on "internal" variable
  internal = "${var.internal}"
  subnets  = "${split(",", var.internal == true ? var.private_subnets : var.public_subnets)}"
  tags     = "${var.tags}"
}

resource "aws_lb_target_group" "main" {
  name                 = "${var.app}-${var.environment}"
  port                 = "${var.lb_port}"
  protocol             = "${var.lb_protocol}"
  vpc_id               = "${var.vpc}"
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    protocol            = "${var.lb_protocol}"
    interval            = "${var.health_check_interval}"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = "${var.tags}"
}

data "aws_elb_service_account" "main" {}
