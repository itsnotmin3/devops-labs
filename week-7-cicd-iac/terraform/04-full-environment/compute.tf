data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web"
  description = "HTTP from anywhere, SSH only if you asked for it"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # A dynamic block: this rule only exists if you supplied a CIDR.
  # The empty default means the SAFE path is the DEFAULT path, rather than
  # the disciplined one. Security you have to remember is security you forget.
  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidr) > 0 ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidr
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-web-sg" }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>${local.name_prefix} — provisioned by Terraform</h1>" > /var/www/html/index.html
    systemctl enable --now nginx
  EOF

  user_data_replace_on_change = true

  tags = { Name = "${local.name_prefix}-web" }
}
