# Adds an https listener to the load balancer, creates the dns entry for it and uses ACM dns based validation to create a certificate

locals {
  hostname = "${var.app}-${var.environment}"
}

data "aws_route53_zone" "app" {
  count = var.domain != "" ? 1 : 0

  name = var.domain
}

locals {
  subdomain = "${local.hostname}.${var.domain}"
}

output "subdomain" {
  value = local.subdomain
}

resource "aws_route53_record" "dns" {
  count = var.domain != "" ? 1 : 0

  zone_id = data.aws_route53_zone.app[0].zone_id
  type    = "CNAME"
  name    = local.subdomain
  records = [aws_alb.main.dns_name]
  ttl     = 30
}

resource "aws_acm_certificate" "cert" {
  count = var.domain != "" ? 1 : 0

  domain_name       = local.subdomain
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  count = var.domain != "" ? 1 : 0

  name    = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.app[0].id
  records = [tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  count = var.domain != "" ? 1 : 0

  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [aws_route53_record.cert_validation[0].fqdn]
}

resource "aws_alb_listener" "dns_https" {
  count = var.domain != "" ? 1 : 0

  load_balancer_arn = aws_alb.main.id
  port              = var.https_port
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.cert[0].certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_security_group_rule" "dns_ingress_lb_https" {
  count = var.domain != "" ? 1 : 0

  type              = "ingress"
  description       = "HTTPS"
  from_port         = var.https_port
  to_port           = var.https_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id
}
