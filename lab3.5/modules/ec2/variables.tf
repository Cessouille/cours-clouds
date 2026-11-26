variable "name" {
  description = "Name of the instance (Name tag), also used to prefix the key pair and security group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Existing subnet to place the instance in"
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key uploaded to AWS"
  type        = string
  default     = "~/.ssh/lab3.5_key.pub"
}
