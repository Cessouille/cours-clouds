terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3.0"
    }
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_key_pair" "this" {
  key_name_prefix = "${var.name}-key-"
  public_key      = file(pathexpand(var.public_key_path))
}

resource "aws_security_group" "ssh" {
  name_prefix = "${var.name}-ssh-"
  description = "Allow SSH inbound"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.this.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ssh.id]
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix         = "${var.name}-asg-"
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = [data.aws_subnet.selected.id]

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }
}

data "aws_instances" "this" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.this.name
  }
  instance_state_names = ["pending", "running"]
}
