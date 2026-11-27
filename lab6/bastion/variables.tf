variable "region" {
  description = "AWS region of the resources"
  type        = string
  default     = "eu-north-1"
}

variable "name" {
  description = "Prefix of the resource names"
  type        = string
  default     = "student_7-lab6-bastion"
}

variable "pair_name" {
  description = "Name of the pair, used in the SSM parameter path /lab6/db/<pair_name>/"
  type        = string
  default     = "student_6_7"
}

variable "vpc_name" {
  description = "Name tag of the VPC"
  type        = string
  default     = "Lab5-6"
}

variable "public_subnet_name" {
  description = "Name tag of the public subnet of the bastion"
  type        = string
  default     = "student_6_7_Public_a"
}

variable "rds_sg_name" {
  description = "Name of the RDS security group, created by student 6"
  type        = string
  default     = "student_6_7_rds"
}

variable "bastion_sg_name" {
  description = "Name of the bastion security group. Student 6 looks it up by this name"
  type        = string
  default     = "student_6_7_bastion"
}

variable "ssh_cidr" {
  description = "Addresses allowed to SSH into the bastion. Default: your current public IP"
  type        = string
  default     = null

  validation {
    condition     = var.ssh_cidr == null || (can(cidrhost(var.ssh_cidr, 0)) && var.ssh_cidr != "0.0.0.0/0")
    error_message = "ssh_cidr must be a CIDR block such as 203.0.113.7/32, and not 0.0.0.0/0."
  }
}

variable "public_key_path" {
  description = "Path to the SSH public key uploaded to AWS"
  type        = string
  default     = "~/.ssh/lab6_key.pub"
}

variable "ami_ssm_parameter" {
  description = "Public SSM parameter holding the ID of the latest Amazon Linux 2 AMI"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
}

variable "create_instance" {
  description = "false creates only the security group and the IAM role, before student 6 opens the database to us"
  type        = bool
  default     = true
}
