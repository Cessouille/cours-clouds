terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.7.0"
    }
  }
}

# Pull nginx image
resource "docker_image" "nginx" {
  name         = "${var.image_name}:${var.image_tag}"
  keep_locally = false
}

# Create nginx container(s)
resource "docker_container" "nginx" {
  count      = var.container_number
  privileged = var.privileged
  image      = docker_image.nginx.image_id
  name       = var.container_number > 1 ? "${lab2}-${count.index + 1}" : "lab2"
  memory     = var.container_memory
  ports {
    internal = 80
    external = var.port_starting_point + count.index
  }
  command = [
    "sh", "-c",
    "sed -i \"s|</body>|<p>Hostname: $(hostname)</p></body>|\" /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"
  ]
}
