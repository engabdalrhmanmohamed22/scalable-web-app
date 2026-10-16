variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "scalable-web"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  description = "true = NAT واحد (أرخص، للتجربة) | false = NAT في كل AZ (High Availability)"
  type        = bool
  default     = false
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "asg_min" {
  type    = number
  default = 2
}

variable "asg_desired" {
  type    = number
  default = 2
}

variable "asg_max" {
  type    = number
  default = 6
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_skip_final_snapshot" {
  description = "للتجربة true. في الإنتاج خليها false"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "الإيميل اللي هيستقبل تنبيهات SNS"
  type        = string
}

# ---------- اختياري: دومين + HTTPS ----------
variable "domain_name" {
  description = "مثال: app.example.com (سيبها فاضية لو مفيش دومين)"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID للدومين"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN (في نفس الـ region) لـ HTTPS على الـ ALB"
  type        = string
  default     = ""
}
