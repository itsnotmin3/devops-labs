resource "aws_s3_bucket" "assets" {
  bucket = "${local.name_prefix}-assets-${var.suffix}"
}

# In AWS provider v4+, versioning/encryption/public-access were SPLIT OUT of
# aws_s3_bucket into separate resources. Every tutorial written before 2022
# shows them as inline arguments and will not work.
#
# This is what a provider major-version bump feels like from the inside, and
# it is why `~> 5.0` is a better constraint than `>= 4.0`.

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
