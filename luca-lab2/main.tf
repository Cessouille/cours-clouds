module "nginx" {
  source = "github.com/LucaCeccarelli/9.5.1-Solutions-Cloud//Lab2/modules/nginx"

  image_to_use               = "${var.image_name}:${var.image_tag}"
  container_memory           = var.container_memory
  container_privileged       = var.privileged
  containers_to_spawn        = var.container_number
  container_port_start_point = var.port_starting_point
}
