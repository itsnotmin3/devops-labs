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

output "ami_used" {
  description = "Which AMI the data source resolved to — changes by region"
  value       = data.aws_ami.ubuntu.id
}

output "account_id" {
  description = "Proof the caller_identity data source works"
  value       = data.aws_caller_identity.current.account_id
}
