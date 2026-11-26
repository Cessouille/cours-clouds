terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3.0"
    }
  }
  required_version = ">= 1.9"

  backend "s3" {
    bucket         = "terraform-state-w9e85"
    key            = "global/s3/student_7/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
