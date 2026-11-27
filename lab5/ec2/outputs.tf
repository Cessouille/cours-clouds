output "asg_names" {
  description = "Names of the Auto Scaling Groups"
  value       = { for app, asg in module.asg : app => asg.asg_name }
}

output "ami_name" {
  description = "AMI found by the datasource"
  value       = data.aws_ami.al2023.name
}

output "urls" {
  description = "Addresses to test the load balancer"
  value       = { for app in keys(var.target_group_names) : app => "http://${data.aws_lb.this.dns_name}/${app}" }
}
