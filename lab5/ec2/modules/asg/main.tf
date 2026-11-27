terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3.0"
    }
  }
}

resource "aws_launch_template" "this" {
  name_prefix            = "${var.name}-lt-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_ids

  # A script saved with Windows line endings does not run on Linux
  user_data = var.user_data == null ? null : base64encode(replace(var.user_data, "\r\n", "\n"))
}

resource "aws_autoscaling_group" "this" {
  name_prefix         = "${var.name}-asg-"
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids

  target_group_arns         = var.target_group_arns
  health_check_type         = length(var.target_group_arns) > 0 ? "ELB" : "EC2"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}
