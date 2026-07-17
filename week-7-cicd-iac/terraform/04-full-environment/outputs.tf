output "web_url" {
  description = "Open this"
  value       = "http://${aws_instance.web.public_ip}"
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_cidr" {
  description = "Computed by cidrsubnet() — not typed by hand"
  value       = aws_subnet.public.cidr_block
}

output "bucket_name" {
  value = aws_s3_bucket.assets.bucket
}
