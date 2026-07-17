terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "web" {
  source = "../../modules/web_server"

  project       = "store"
  environment   = "prod"
  vpc_cidr      = "10.2.0.0/16" # must not overlap staging
  instance_type = "t3.small"    # bigger — it is prod
}

output "prod_url" {
  value = module.web.web_url
}
