provider "aws" {
  region = var.region
}

module "asg" {
  source = "./modules/asg"

  name            = var.name
  instance_name   = "${var.name}-${terraform.workspace}"
  instance_type   = var.instance_type
  min_size        = var.min_size
  max_size        = var.max_size
  subnet_id       = var.subnet_id
  public_key_path = var.public_key_path
}
