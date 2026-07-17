# The Week 3 networking diagram, as code.
#
# Read this top to bottom. There is nothing in it you have not already met —
# the only difference is that clicking it in the console hides the structure,
# and twenty lines of HCL make it impossible to miss.

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${local.name_prefix}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  # The Week 3 CIDR arithmetic, automated:
  # take a /16, add 8 bits -> a /24, give me the second one = 10.0.1.0/24
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = { Name = "${local.name_prefix}-public" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${local.name_prefix}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                  # everything not local...
    gateway_id = aws_internet_gateway.main.id # ...goes to the internet
  }

  tags = { Name = "${local.name_prefix}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# WHAT MAKES A SUBNET "PUBLIC"?
#
# Nothing about the subnet itself. There is no `public = true` flag.
#
# A subnet is public because its ROUTE TABLE has a 0.0.0.0/0 route to an
# INTERNET GATEWAY. That is the entire definition. Delete the route above and
# the identical subnet becomes private.
# ---------------------------------------------------------------------------
