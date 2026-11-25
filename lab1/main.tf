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

# Pull nginx image
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

# Create nginx container
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "lab1"
  ports {
    internal = 80
    external = 8000
  }
  command = [
    "sh", "-c",
    "sed -i \"s|</body>|<p>Hostname: $(hostname)</p></body>|\" /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"
  ]
}
