output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}

output "public_ips" {
  description = "Public IPs of the instances"
  value       = data.aws_instances.this.public_ips
}
