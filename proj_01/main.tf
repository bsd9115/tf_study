resource "aws_vpc" "bsc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "bsc_public_subnet" {
  vpc_id                  = aws_vpc.bsc_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "bsc_ineternet_gateway" {
  vpc_id = aws_vpc.bsc_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "bsc_public_rt" {
  vpc_id = aws_vpc.bsc_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.bsc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bsc_ineternet_gateway.id
}

resource "aws_route_table_association" "bsc_public_assoc" {
  subnet_id      = aws_subnet.bsc_public_subnet.id
  route_table_id = aws_route_table.bsc_public_rt.id
}

