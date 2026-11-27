provider "aws" {
  region = var.region
}

data "aws_vpc" "lab" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "private" {
  vpc_id = data.aws_vpc.lab.id

  filter {
    name   = "tag:Name"
    values = [var.private_subnet_name]
  }
}

data "aws_security_group" "internal" {
  vpc_id = data.aws_vpc.lab.id
  name   = var.internal_sg_name
}

data "aws_lb" "this" {
  name = var.alb_name
}

data "aws_lb_target_group" "this" {
  for_each = var.target_group_names

  name = each.value
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# One ASG per application: nginx and tomcat

module "asg" {
  source   = "./modules/asg"
  for_each = var.target_group_names

  name               = "${var.name}-${each.key}"
  ami_id             = data.aws_ami.al2023.id
  min_size           = 2
  max_size           = 2
  subnet_ids         = [data.aws_subnet.private.id]
  security_group_ids = [data.aws_security_group.internal.id]
  target_group_arns  = [data.aws_lb_target_group.this[each.key].arn]

  user_data = <<-EOF
    #!/bin/bash
    TOKEN=$(curl -s -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
    ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
    mkdir -p /srv/${each.key}
    echo "<h1>${each.key}</h1><p>served by $ID</p>" | tee /srv/index.html /srv/${each.key}/index.html
    cd /srv && nohup python3 -m http.server 80 >/dev/null 2>&1 &
  EOF
}
