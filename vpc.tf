resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "flashmind-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet("10.0.0.0/24", 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "flashmind-public-${count.index}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.1.0/24", 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "flashmind-private-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associate Public Subnets with Public Route Table
# For each public subnet, associate it with the public route table so it knows how to route traffic (e.g., to the Internet via IGW).
resource "aws_route_table_association" "public" {
  # You're looping over all the public subnets (which is 2 in your case)
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
}

# NAT Gateway for Private Subnets
# etting up a NAT Gateway to allow private subnets to access the internet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.main]
}

# Private Route Table
# Sends all outbound traffic (0.0.0.0/0) to the NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

# Associate Private Subnets with Private Route Table
# This loops through all private subnets and associates each one with the private route table above.
# everything outside local ip route to IGW
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Get Available AZs
data "aws_availability_zones" "available" {}
