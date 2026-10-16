output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "app_url_via_cloudfront" {
  value = "https://${aws_cloudfront_distribution.this.domain_name}"
}

output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_secret_arn" {
  description = "الباسورد بتاع الـ DB هنا في Secrets Manager"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "asg_name" {
  value = aws_autoscaling_group.web.name
}

output "ssm_connect_hint" {
  value = "aws ssm start-session --target <instance-id> --region ${var.region}"
}
