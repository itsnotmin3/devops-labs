variable "project" {
  description = "Project name — used in every resource name and tag"
  type        = string
  default     = "bootcamp"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  # No default = REQUIRED. Terraform refuses to run without it.

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "suffix" {
  description = "Random digits — S3 bucket names are globally unique"
  type        = string
}
