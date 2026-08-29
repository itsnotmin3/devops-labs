# Lab 03 — deploy an EC2 instance.
#
# The same pattern as the bucket, pointed at compute instead of storage:
# provider + resource + variables + outputs.
#
#   terraform init
#   terraform plan
#   terraform apply
#   terraform apply      # again — "No changes" = idempotency
#   terraform destroy    # ALWAYS

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
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
