# 02 — variables, locals and outputs.
#
# Hard-coding "ap-south-1" and a bucket name works exactly until you need a
# second environment. This is how ONE configuration serves staging AND prod.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  # Every taggable resource inherits these. Set once, never forget a tag
  # on the one resource that turns out to be expensive.
  default_tags {
    tags = local.common_tags
  }
}

locals {
  # A local is a shorthand INSIDE the config. Computed once, used everywhere.
  # Unlike a variable, nobody can override it.
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  is_prod = var.environment == "prod"
}

resource "aws_s3_bucket" "assets" {
  bucket = "${local.name_prefix}-assets-${var.suffix}"
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    # is_prod is computed in locals — a conditional, not an if statement.
    status = local.is_prod ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
