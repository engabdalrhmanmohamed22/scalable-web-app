# Evidence checklist (before submitting)

Put the files in `docs/screenshots/` and reference them from the README.

| # | Test | Evidence to capture | Suggested file name | Status |
|---|---|---|---|---|
| 1 | Site via CloudFront | Browser screenshot showing Instance ID + AZ (refresh once to show it changes) | `01-site-cloudfront.png` | have it |
| 2 | ALB rule `/admin/` | Terminal output with `403 Forbidden` | `02-admin-403.png` | have it |
| 3 | WAF block | `curl` with `<script>` returning 403 | `03-waf-403.png` | missing |
| 4 | CloudFront cache | `curl -I` twice showing `X-Cache: Miss` then `Hit` | `04-cloudfront-cache.png` | missing |
| 5 | Session Manager | Shell opened via `aws ssm start-session` | `05-session-manager.png` | missing |
| 6 | Auto Scaling | ASG activity history / instance count above 2 | `06-autoscaling.png` | missing |
| 7 | RDS failover | RDS console before/after AZ change | `07-rds-failover.png` | missing |
| 8 | Terraform outputs | `terraform apply` final output (hide account IDs) | `08-outputs.png` | optional |
| 9 | Dashboard / alarms | CloudWatch dashboard screenshot | `09-dashboard.png` | optional |

Optional deliverable: a short screen recording (2-4 min) walking through the architecture, the live URL, the `/admin/` 403, and an auto-scaling or failover test. Upload it (YouTube unlisted / Drive) and put the link at the top of the README.
