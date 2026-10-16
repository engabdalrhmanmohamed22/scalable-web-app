#!/bin/bash
set -euxo pipefail

dnf install -y nginx

TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
IID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

mkdir -p /usr/share/nginx/html/static

cat > /usr/share/nginx/html/static/style.css <<CSS
body{font-family:sans-serif;background:#0f172a;color:#e2e8f0;text-align:center;padding-top:80px}
.card{display:inline-block;background:#1e293b;padding:32px 48px;border-radius:12px}
CSS

cat > /usr/share/nginx/html/index.html <<HTML
<!doctype html>
<html><head><meta charset="utf-8"><title>Scalable Web App</title>
<link rel="stylesheet" href="/static/style.css"></head>
<body><div class="card">
<h1>Hello from AWS 🚀</h1>
<p>Instance: <b>$IID</b></p>
<p>AZ: <b>$AZ</b></p>
</div></body></html>
HTML

# Health check endpoint للـ ALB
cat > /etc/nginx/default.d/health.conf <<'NGINX'
location = /health {
    access_log off;
    add_header Content-Type text/plain;
    return 200 "ok";
}
NGINX

systemctl enable --now nginx
