variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 size (t3.micro is free-tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI id for your region (check the console)"
  type        = string
  default     = "ami-0905a3c97561e0b69"
}

variable "key_name" {
  description = "Name of an EXISTING EC2 key pair to SSH in with"
  type        = string
}

variable "my_ip" {
  description = "Your public IP in CIDR form, e.g. 1.2.3.4/32 (curl ifconfig.me)"
  type        = string
}
