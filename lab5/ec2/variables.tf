variable "region" {
  description = "AWS region of the resources"
  type        = string
  default     = "eu-north-1"
}

variable "name" {
  description = "Prefix of the resource names"
  type        = string
  default     = "student_7-lab5"
}

variable "vpc_name" {
  description = "Name tag of the VPC"
  type        = string
  default     = "Lab5-6"
}

variable "private_subnet_name" {
  description = "Name tag of the private subnet"
  type        = string
  default     = "student_6_7_Private"
}

variable "internal_sg_name" {
  description = "Name of the security group of the instances"
  type        = string
  default     = "student_6_7_internal"
}

variable "alb_name" {
  description = "Name of the application load balancer"
  type        = string
  default     = "student-6-7-alb"
}

variable "target_group_names" {
  description = "Target group of each application. One ASG is created per entry, the key being the URL path"
  type        = map(string)
  default = {
    nginx  = "student-6-7-nginx"
    tomcat = "student-6-7-tomcat"
  }
}

variable "ami_name" {
  description = "Name pattern of the Amazon AMI of the instances"
  type        = string
  default     = "al2023-ami-2023.*-x86_64"
}
