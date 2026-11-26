variable "access_key" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "subnet_id" {
  description = "Existing subnet to place the instance in (read through a datasource)"
  type        = string
  default     = "subnet-0855fbfcf29f845c3"
}

variable "name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "lab3-ec2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "public_key_path" {
  description = "Path to the SSH public key uploaded to AWS"
  type        = string
  default     = "~/.ssh/lab3.5_key.pub"
}
