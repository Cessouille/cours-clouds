provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "ec2" {
  source = "./modules/ec2"

  name            = var.name
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  public_key_path = var.public_key_path
}
