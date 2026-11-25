terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.7.0"
    }
  }
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}

module "nginx" {
  source = "./modules/nginx"

  image_name          = var.image_name
  image_tag           = var.image_tag
  container_memory    = var.container_memory
  privileged          = var.privileged
  container_number    = var.container_number
  port_starting_point = var.port_starting_point
}
