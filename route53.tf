locals {
  dns_enabled = var.domain_name != "" && var.hosted_zone_id != ""
}

# Alias record -> ALB
resource "aws_route53_record" "app" {
  count   = local.dns_enabled ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

# Health check على الـ ALB
resource "aws_route53_health_check" "alb" {
  count             = local.dns_enabled ? 1 : 0
  type              = local.https_enabled ? "HTTPS" : "HTTP"
  fqdn              = aws_lb.this.dns_name
  port              = local.https_enabled ? 443 : 80
  resource_path     = "/health"
  request_interval  = 30
  failure_threshold = 3
  tags              = { Name = "${local.name}-alb-hc" }
}
