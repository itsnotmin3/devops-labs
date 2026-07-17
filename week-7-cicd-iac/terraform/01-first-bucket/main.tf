# 01 — the smallest Terraform configuration that really works.
#
# Nothing is missing from this file. Fifteen lines, one real bucket.
# Everything after this adds ONE idea at a time.
#
#   terraform init      download the AWS provider
#   terraform plan      show me what you WOULD do (read this, every time)
#   terraform apply     do it
#   terraform apply     do it again — watch nothing happen (idempotency)
#   terraform destroy   remove it (do this before you close the laptop)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # >= 5.0, < 6.0 — minor updates ok, no major breaks
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  # NO access_key / secret_key here. Ever. Terraform reads the same
  # credentials the AWS CLI uses: `aws configure`, or env vars, or a role.
}

resource "aws_s3_bucket" "demo" {
  #        └── type ──┘  └name┘   type = what it is, name = what YOU call it
  bucket = "bootcamp-tf-demo-4471" # <- CHANGE THIS. Names are globally unique
  #                                     across every AWS customer on Earth.
}
