#!/bin/bash
# Runs ONCE on the instance's first boot (EC2 user_data).
# Installs NGINX and writes a page — so the server is serving before you ever SSH in.
apt-get update -y
apt-get install -y nginx
echo "<h1>Hello from EC2</h1><p>Provisioned by the VPC + EC2 lab.</p>" > /var/www/html/index.html
systemctl enable --now nginx
