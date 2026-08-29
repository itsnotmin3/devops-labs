output "public_ip" {
  description = "The instance's public IP"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "The instance's public DNS name"
  value       = aws_instance.web.public_dns
}
