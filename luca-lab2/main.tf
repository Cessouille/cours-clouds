module "nginx" {
  source = "github.com/LucaCeccarelli/9.5.1-Solutions-Cloud//Lab2/modules/nginx"

  containers_to_spawn = 3
}
