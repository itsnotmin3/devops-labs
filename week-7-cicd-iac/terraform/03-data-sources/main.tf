# 03 — data sources, dependencies, and a real server.
#
# A `resource` says "make this exist".
# A `data` source says "go FIND something that already exists".
# Terraform never creates, changes or destroys what a data source finds.

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

# ---------------------------------------------------------------------------
# THE FIX THIS LAB IS ABOUT
#
# The obvious thing is to hard-code an AMI:
#     ami = "ami-0f5ee92e2d63afc18"
#
# Do not. AMI ids are REGION-SPECIFIC and they go stale within weeks.
# That one id does not exist in us-east-1 at all. Hard-coding it is the single
# most common reason a Terraform config works for its author and fails for
# everybody else on the team.
#
# A data source looks up the CURRENT Ubuntu image in WHATEVER region the
# provider is pointed at. Same config, any region, forever.
# ---------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's account id

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ap-south-1a is not a fact about AWS — it is a fact about ONE region.
# Ask instead of assuming.
data "aws_availability_zones" "available" {
  state = "available"
}

# Who am I? Useful in policies and outputs.
data "aws_caller_identity" "current" {}

# ---- firewall: SSH from YOUR ip only, HTTP from anywhere ----
resource "aws_security_group" "web" {
  name        = "bootcamp-web-sg"
  description = "Allow SSH from my IP and HTTP from anywhere"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # never 0.0.0.0/0
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 = every protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "bootcamp-web-sg" }
}

# ---- the server ----
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id # note the `data.` prefix
  instance_type = var.instance_type
  key_name      = var.key_name

  # THIS reference is what creates the dependency. Terraform now knows the
  # security group must exist first — you never told it the order.
  # Hard-code an sg id here instead and you sever that edge in the graph,
  # and then you need depends_on to paper over it. Reference, don't hard-code.
  vpc_security_group_ids = [aws_security_group.web.id]

  availability_zone = data.aws_availability_zones.available.names[0]

  # Runs once, on FIRST boot only.
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>Provisioned by Terraform</h1>" > /var/www/html/index.html
    echo "<p>AMI: ${data.aws_ami.ubuntu.id}</p>" >> /var/www/html/index.html
    systemctl enable --now nginx
  EOF

  # Without this, editing user_data updates the attribute in state and
  # changes NOTHING on the box — because user_data only runs on first boot.
  # Your edit silently never happens. This forces a rebuild instead.
  user_data_replace_on_change = true

  tags = { Name = "bootcamp-web" }
}
