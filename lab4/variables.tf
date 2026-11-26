variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "subnet_id" {
  description = "Existing subnet to place the instances in"
  type        = string
  default     = "subnet-0855fbfcf29f845c3"
}

variable "name" {
  description = "Prefix of the resource names"
  type        = string
  default     = "student_7-lab4"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
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

variable "public_key_path" {
  description = "Path to the SSH public key uploaded to AWS"
  type        = string
  default     = "~/.ssh/lab4_key.pub"
}
