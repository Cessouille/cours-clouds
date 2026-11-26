variable "name" {
  description = "Prefix of the resource names"
  type        = string
}

variable "instance_name" {
  description = "Name tag of the instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
}

variable "subnet_id" {
  description = "Existing subnet to place the instances in"
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key uploaded to AWS"
  type        = string
}
