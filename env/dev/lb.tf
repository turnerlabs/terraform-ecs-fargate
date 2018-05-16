# note that this creates the alb, target group, and access logs
# the listeners are defined in lb-http.tf and lb-https.tf
# delete either of these if your app doesn't need them
# but you need at least one

resource "aws_alb" "main" {
  name = "${var.app}-${var.environment}"

  # launch lbs in public or private subnets based on "internal" variable
  internal        = "${var.internal}"
  subnets         = "${split(",", var.internal == true ? var.private_subnets : var.public_subnets)}"
  security_groups = ["${aws_security_group.nsg_lb.id}"]
  tags            = "${var.tags}"

  # enable access logs in order to get support from aws
  access_logs {
    enabled = true
    bucket  = "${aws_s3_bucket.lb_access_logs.bucket}"
  }
}

resource "aws_alb_target_group" "main" {
  name                 = "${var.app}-${var.environment}"
  port                 = "${var.lb_port}"
  protocol             = "${var.lb_protocol}"
  vpc_id               = "${var.vpc}"
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    path                = "${var.health_check}"
    matcher             = "${var.health_check_matcher}"
    interval            = "${var.health_check_interval}"
    timeout             = "${var.health_check_timeout}"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = "${var.tags}"
}

data "aws_elb_service_account" "main" {}

# bucket for storing ALB access logs
resource "aws_s3_bucket" "lb_access_logs" {
  bucket        = "${var.app}-${var.environment}-lb-access-logs"
  acl           = "private"
  tags          = "${var.tags}"
  force_destroy = true

  lifecycle_rule {
    id                                     = "cleanup"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1
    prefix                                 = "/"

    expiration {
      days = 3
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# give load balancing service access to the bucket
resource "aws_s3_bucket_policy" "lb_access_logs" {
  bucket = "${aws_s3_bucket.lb_access_logs.id}"

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.lb_access_logs.arn}",
        "${aws_s3_bucket.lb_access_logs.arn}/*"
      ],
      "Principal": {
        "AWS": [ "${data.aws_elb_service_account.main.arn}" ]
      }
    }
  ]
}
POLICY
}
