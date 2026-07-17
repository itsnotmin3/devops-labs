terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# The provider lives in the CALLER, not the module.
provider "aws" {
  region = "ap-south-1"
}

module "web" {
  source = "../../modules/web_server"

  project       = "store"
  environment   = "staging"
  vpc_cidr      = "10.1.0.0/16" # must not overlap prod
  instance_type = "t3.micro"    # small — it is staging
}

output "staging_url" {
  value = module.web.web_url
}
