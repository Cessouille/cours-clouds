variable "name" {
  description = "Name of the instances, also used as prefix of the resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI of the instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number

  validation {
    condition     = var.min_size >= 0
    error_message = "min_size must be 0 or more."
  }
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number

  validation {
    condition     = var.max_size >= var.min_size
    error_message = "max_size must be greater than or equal to min_size."
  }
}

variable "subnet_ids" {
  description = "Subnets the instances are created in"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids needs at least one subnet."
  }
}

variable "security_group_ids" {
  description = "Security groups of the instances"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Load balancer target groups the instances are registered in"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "Script run at the first boot of each instance"
  type        = string
  default     = null
}

variable "health_check_grace_period" {
  description = "Seconds a new instance has to start before its health is checked"
  type        = number
  default     = 300
}
