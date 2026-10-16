resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-db-subnets"
  subnet_ids = aws_subnet.db[*].id
}

resource "aws_db_instance" "this" {
  identifier     = "${local.name}-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  # الباسورد بيتخزن وبيتعمله rotate في Secrets Manager (مش في الـ state)
  manage_master_user_password = true

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  backup_retention_period = 1
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:03:30-sun:04:30"

  performance_insights_enabled    = false
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  deletion_protection       = false
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = var.db_skip_final_snapshot ? null : "${local.name}-final"
}
