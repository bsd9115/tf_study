resource "aws_vpc" "bsd_9115_vpc" {
  cidr_block           = "10.19.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

# Configure Subnet
resource "aws_subnet" "bsd_9115_public_subnet" {
  vpc_id                  = aws_vpc.bsd_9115_vpc.id
  cidr_block              = "10.19.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"

  tags = {
    Name = "dev-public"
  }
}

# Configure Internet Gateway
resource "aws_internet_gateway" "bsd_9115_ineternet_gateway" {
  vpc_id = aws_vpc.bsd_9115_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

# Configure Routing Table
resource "aws_route_table" "bsd_9115_public_rt" {
  vpc_id = aws_vpc.bsd_9115_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id            = aws_route_table.bsd_9115_public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.bsd_9115_ineternet_gateway.id
}

# Routing Table association
resource "aws_route_table_association" "bsd_9115_public_assoc" {
  subnet_id      = aws_subnet.bsd_9115_public_subnet.id
  route_table_id = aws_route_table.bsd_9115_public_rt.id
}

# Configure Security Group
resource "aws_security_group" "bsd_9115_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.bsd_9115_vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev_sg"
  }
}

resource "aws_key_pair" "bsc_auth" {
  key_name   = "bsdkey"
  public_key = file("~/.ssh/bsdkey.pub")
}