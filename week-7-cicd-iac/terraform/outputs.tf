output "public_ip" {
  description = "Public IP of the instance Terraform created"
  value       = aws_instance.web.public_ip
}

output "url" {
  description = "Open this in a browser"
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  description = "Copy-paste to log in"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.web.public_ip}"
}
