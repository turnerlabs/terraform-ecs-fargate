# adds an http listener to the load balancer and allows ingress
# (delete this file if you only want https)

resource "aws_alb_listener" "http" {
  # Don't do standard http hosting if redirect is enabled
  count = var.do_https_redirect ? 0 : 1

  load_balancer_arn = aws_alb.main.id
  port              = var.lb_port
  protocol          = var.lb_protocol

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "http_redirect" {
  # Redirect http to https when enabled
  count = var.do_https_redirect ? 1 : 0

  load_balancer_arn = aws_alb.main.id
  port              = var.lb_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group_rule" "ingress_lb_http" {
  type              = "ingress"
  description       = var.lb_protocol
  from_port         = var.lb_port
  to_port           = var.lb_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id
}
