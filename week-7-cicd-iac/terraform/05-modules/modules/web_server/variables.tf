# These are the module's INPUTS — its function signature.
#
# What varies between callers becomes a variable. What does not, does not.
# A module with 40 variables is a module that could not decide what it was for.

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "dev / staging / prod"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for this environment's VPC — must not overlap the others"
  type        = string
}

variable "instance_type" {
  description = "EC2 size"
  type        = string
  default     = "t3.micro"
}
