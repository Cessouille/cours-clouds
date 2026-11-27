terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3.0"
    }

    # Only used to find our public IP, for the SSH rule
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
  required_version = ">= 1.9"

  # BASTION state (student 7). Student 6 has network_rds.tfstate next to it.
  # region here = where the bucket is (Paris), not where we deploy.
  backend "s3" {
    bucket         = "terraform-state-w9e85"
    key            = "global/s3/student_6_7/bastion.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
