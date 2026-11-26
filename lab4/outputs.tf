output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.asg_name
}

output "public_ips" {
  description = "Public IPs of the instances"
  value       = module.asg.public_ips
}
