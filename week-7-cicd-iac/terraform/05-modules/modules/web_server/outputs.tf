# The module's RETURN values. The caller reads these as
#   module.<name>.<output>

output "web_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
