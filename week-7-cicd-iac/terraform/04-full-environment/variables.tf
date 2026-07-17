variable "project" {
  type    = string
  default = "bootcamp"
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name. Leave null to skip SSH entirely."
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "Who may reach port 22. Empty = nobody, which is the safe default."
  type        = list(string)
  default     = []
}

variable "suffix" {
  description = "Random digits — S3 bucket names are globally unique"
  type        = string
}
