variable "region" {
  default = "ap-south-1"
}

# An AMI id names a disk image in ONE region. This is Ubuntu 24.04 in
# ap-south-1 — if you change the region, change this too.
variable "ami_id" {
  default = "ami-0f5ee92e2d63afc18"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "instance_name" {
  default = "web-server"
}
