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

variable "vpc_id" {
  description = "Existing main VPC"
  type        = string
  default     = "vpc-01b6138c71cc82aba"
}

variable "subnet_id" {
  description = "Existing subnet to place the instance in"
  type        = string
  default     = "subnet-0855fbfcf29f845c3"
}

variable "ami" {
  description = "AMI used for the instance"
  type        = string
  default     = "ami-092c64119783c2f31"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "public_key_path" {
  description = "Path to the SSH public key uploaded to AWS"
  type        = string
  default     = "~/.ssh/lab3_key.pub"
}
