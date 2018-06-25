# adds an http listener to the load balancer and allows ingress
# (delete this file if you only want https)

resource "aws_lb_listener" "tcp" {
  load_balancer_arn = "${aws_lb.main.id}"
  port              = "${var.lb_port}"
  protocol          = "${var.lb_protocol}"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.id}"
    type             = "forward"
  }
}
