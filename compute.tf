data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "web" {
  name_prefix   = "${local.name}-lt-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = base64encode(file("${path.module}/user_data.sh"))

  # IMDSv2 إجباري
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10
      volume_type = "gp3"
      encrypted   = true
    }
  }

  monitoring { enabled = true }

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${local.name}-web" }
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${local.name}-asg"
  min_size                  = var.asg_min
  max_size                  = var.asg_max
  desired_capacity          = var.asg_desired
  vpc_zone_identifier       = aws_subnet.private[*].id
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  enabled_metrics = ["GroupInServiceInstances", "GroupDesiredCapacity", "GroupTotalInstances"]

  tag {
    key                 = "Name"
    value               = "${local.name}-web"
    propagate_at_launch = true
  }

  lifecycle { ignore_changes = [desired_capacity] }
}

# ---------- Target tracking: CPU ----------
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${local.name}-cpu-target-50"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}

# ---------- Target tracking: Requests per target ----------
resource "aws_autoscaling_policy" "req_target" {
  name                   = "${local.name}-req-per-target"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.this.arn_suffix}/${aws_lb_target_group.web.arn_suffix}"
    }
    target_value = 500
  }
}

# ---------- Step scaling: scale-out سريع لو CPU عالي جداً ----------
resource "aws_autoscaling_policy" "step_out" {
  name                   = "${local.name}-step-scale-out"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 10
  }
  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = 10
  }
}
