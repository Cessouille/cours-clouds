output "public_dns" {
  description = "Public DNS name of the instance"
  value       = module.ec2.public_dns
}

output "public_ip" {
  description = "Public IP of the instance"
  value       = module.ec2.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/lab3.5_key ec2-user@${module.ec2.public_dns}"
}
