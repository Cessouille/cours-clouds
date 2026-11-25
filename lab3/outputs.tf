output "public_ip" {
  value = aws_instance.lab3.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/lab3_key ec2-user@${aws_instance.lab3.public_ip}"
}
