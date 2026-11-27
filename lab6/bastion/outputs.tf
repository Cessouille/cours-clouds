output "bastion_public_ip" {
  description = "Public IP of the bastion"
  value       = one(aws_instance.bastion[*].public_ip)
}

output "ssh_command" {
  description = "Command to connect to the bastion"
  value       = one([for instance in aws_instance.bastion : "ssh -i ${trimsuffix(var.public_key_path, ".pub")} ec2-user@${instance.public_ip}"])
}

output "bastion_security_group_id" {
  description = "To give to student 6, who allows it on port 5432"
  value       = aws_security_group.bastion.id
}

output "rds_security_group_id" {
  description = "RDS security group of student 6"
  value       = data.aws_security_group.rds.id
}

output "instance_id" {
  description = "ID of the bastion, the target of Session Manager"
  value       = one(aws_instance.bastion[*].id)
}

output "database" {
  description = "Database information read from the parameters of student 6 (no password)"
  value       = { for key, parameter in data.aws_ssm_parameter.db : key => nonsensitive(parameter.value) }
}
