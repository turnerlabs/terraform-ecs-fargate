resource "aws_security_group" "nsg_task" {
  name        = "${var.app}-${var.environment}-task"
  description = "Limit connections from internal resources while allowing ${var.app}-${var.environment}-task to connect to all external resources"
  vpc_id      = "${var.vpc}"

  tags = "${var.tags}"
}

# Rules for the TASK (Targets the LB SG)
resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  description = "Only allow connections from SG ${var.app}-${var.environment}-lb on port ${var.container_port}"
  type        = "ingress"
  from_port   = "${var.container_port}"
  to_port     = "${var.container_port}"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.nsg_task.id}"
}

resource "aws_security_group_rule" "nsg_task_egress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.nsg_task.id}"
}
