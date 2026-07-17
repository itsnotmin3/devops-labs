variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1" # Mumbai
}

variable "instance_type" {
  description = "EC2 size (t3.micro is free-tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an EXISTING EC2 key pair to SSH in with"
  type        = string
}

variable "my_ip" {
  description = "Your public IP in CIDR form, e.g. 1.2.3.4/32 (curl ifconfig.me)"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.my_ip))
    error_message = "my_ip must be CIDR notation — add /32 to a single IP."
  }
}
