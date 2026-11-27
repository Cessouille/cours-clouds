provider "aws" {
  region = var.region
}

locals {
  ssm_prefix = "/lab6/db/${var.pair_name}"
  ssh_cidr   = var.ssh_cidr != null ? var.ssh_cidr : "${chomp(data.http.my_ip[0].response_body)}/32"
}

# Network (read only)

data "aws_vpc" "lab" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "public" {
  vpc_id = data.aws_vpc.lab.id

  filter {
    name   = "tag:Name"
    values = [var.public_subnet_name]
  }
}

# Resources of student 6 (read only). The plan fails if they do not exist yet.
# The password is deliberately not read here: it would be saved in our state.

data "aws_security_group" "rds" {
  vpc_id = data.aws_vpc.lab.id
  name   = var.rds_sg_name
}

data "aws_ssm_parameter" "db" {
  for_each = toset(["endpoint", "name", "username"])

  name = "${local.ssm_prefix}/${each.key}"
}

# Bastion security group: SSH from our IP only. Student 6 allows it on the RDS side.

data "http" "my_ip" {
  count = var.ssh_cidr == null ? 1 : 0

  url = "https://checkip.amazonaws.com"

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Could not find your public IP. Set the ssh_cidr variable."
    }
  }
}

resource "aws_security_group" "bastion" {
  name        = var.bastion_sg_name
  description = "Lab 6 bastion: SSH from my IP only"
  vpc_id      = data.aws_vpc.lab.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.bastion_sg_name
  }
}

# IAM role of the bastion

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "bastion" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Read the database parameters of our pair, and nothing else.
# SecureString with the default aws/ssm key needs no extra KMS permission.
resource "aws_iam_role_policy" "read_db_parameters" {
  name = "read-db-parameters"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "ssm:GetParameter"
      Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_prefix}/*"
    }]
  })
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.name}-profile"
  role = aws_iam_role.bastion.name
}

# Bastion instance

data "aws_ssm_parameter" "al2_ami" {
  name = var.ami_ssm_parameter
}

resource "aws_key_pair" "bastion" {
  key_name_prefix = "${var.name}-key-"
  public_key      = file(pathexpand(var.public_key_path))
}

resource "aws_instance" "bastion" {
  count = var.create_instance ? 1 : 0

  ami                         = nonsensitive(data.aws_ssm_parameter.al2_ami.value)
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion.key_name
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  # A script saved with Windows line endings does not run on Linux
  user_data = replace(templatefile("${path.module}/user_data.sh.tftpl", {
    region     = var.region
    ssm_prefix = local.ssm_prefix
  }), "\r\n", "\n")
  user_data_replace_on_change = true

  # Metadata service with tokens only (IMDSv2)
  metadata_options {
    http_tokens = "required"
  }

  # The permission must exist before the instance is used
  depends_on = [aws_iam_role_policy.read_db_parameters]

  tags = {
    Name = var.name
  }
}
