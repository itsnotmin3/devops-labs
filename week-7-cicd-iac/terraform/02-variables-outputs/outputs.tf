output "bucket_name" {
  description = "The bucket Terraform created"
  value       = aws_s3_bucket.assets.bucket
}

output "bucket_arn" {
  description = "Its ARN — you would feed this to an IAM policy"
  value       = aws_s3_bucket.assets.arn
}

output "versioning_enabled" {
  description = "Proof the conditional worked"
  value       = local.is_prod
}
