resource "aws_wafv2_web_acl" "alb" {
  name  = "${local.name}-alb-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # --- AWS Managed Rules (OWASP Top 10) ---
  dynamic "rule" {
    for_each = {
      common    = { name = "AWSManagedRulesCommonRuleSet", priority = 10 }
      badinputs = { name = "AWSManagedRulesKnownBadInputsRuleSet", priority = 20 }
      sqli      = { name = "AWSManagedRulesSQLiRuleSet", priority = 30 }
      linux     = { name = "AWSManagedRulesLinuxRuleSet", priority = 40 }
    }
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  # --- Rate limit: 2000 request / 5 min لكل IP ---
  rule {
    name     = "RateLimitPerIP"
    priority = 50

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitPerIP"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name}-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.this.arn
  web_acl_arn  = aws_wafv2_web_acl.alb.arn
}
