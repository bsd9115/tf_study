# VPC 생성
resource "aws_vpc" "my_vpc" {
 cidr_block = "10.0.0.0/16"
 enable_dns_hostnames = true
 enable_dns_support = true
 tags = {
 Name = "my_vpc"
 }
}
# Subnet 생성(availability_zone1)
resource "aws_subnet" "my_public_subnet1" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block = "10.0.1.0/24"
 availability_zone = var.availability_zone1
 map_public_ip_on_launch = true
 tags = {
 Name = "my_public_subnet1"
 }
}
resource "aws_subnet" "my_private_subnet1" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block = "10.0.2.0/24"
 availability_zone = var.availability_zone1
 tags = {
 Name = "my_private_subnet1"
 }
}
resource "aws_subnet" "my_private_subnet2" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block = "10.0.3.0/24"
 availability_zone = var.availability_zone1
 tags = {
 Name = "my_private_subnet2"
 }
}
# Subnet 생성(availability_zone2)
resource "aws_subnet" "my_public_subnet2" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block = "10.0.101.0/24"
 availability_zone = var.availability_zone2
 map_public_ip_on_launch = true
 tags = {
 Name = "my_public_subnet2"
 }
}
resource "aws_subnet" "my_private_subnet3" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block = "10.0.102.0/24"
 availability_zone = var.availability_zone2
 tags = {
 Name = "my_private_subnet3"
 }
}
resource "aws_subnet" "my_private_subnet4" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block = "10.0.103.0/24"
 availability_zone = var.availability_zone2
 tags = {
 Name = "my_private_subnet4"
 }
}
# Internet Gateway 생성
resource "aws_internet_gateway" "my_IGW" {
 vpc_id = aws_vpc.my_vpc.id
 tags = {
 Name = "my_IGW"
 }
}
# EIP 주소 할당
resource "aws_eip" "NAT_EIP" {
 vpc = true
 lifecycle {
 create_before_destroy = true
 }
}
# NAT Gateway 생성 – EIP 주소 연결
resource "aws_nat_gateway" "my_NATGW" {
 allocation_id = aws_eip.NAT_EIP.id
 subnet_id = aws_subnet.my_public_subnet1.id
 tags = {
 Name = "my_NATGW"
 }
 depends_on = [aws_internet_gateway.my_IGW]
}
# 라우팅 테이블 설정 & 라우팅 테이블 - 서브넷 연결
# public_RT1
resource "aws_route_table" "my_public_RT" {
 vpc_id = aws_vpc.my_vpc.id
 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.my_IGW.id
 }
 tags = {
 Name = "my_public_RT"
 }
}
resource "aws_route_table_association" "public_RT1_assoc" {
 subnet_id = aws_subnet.my_public_subnet1.id
 route_table_id = aws_route_table.my_public_RT.id
}
# public_RT2
resource "aws_route_table_association" "public_RT2_assoc" {
 subnet_id = aws_subnet.my_public_subnet2.id
 route_table_id = aws_route_table.my_public_RT.id
}
# private_RT1
resource "aws_route_table" "my_private_RT1" {
 vpc_id = aws_vpc.my_vpc.id
 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = aws_nat_gateway.my_NATGW.id
 }
 tags = {
 Name = "my_private_RT1"
 }
}
resource "aws_route_table_association" "private1_RT1_assoc" {
 subnet_id = aws_subnet.my_private_subnet1.id
 route_table_id = aws_route_table.my_private_RT1.id
}
# vi database/variables.tf
# private_RT2
resource "aws_route_table_association" "private3_RT1_assoc" {
 subnet_id = aws_subnet.my_private_subnet3.id
 route_table_id = aws_route_table.my_private_RT1.id
}
# private_RT3
resource "aws_route_table" "my_private_RT2" {
 vpc_id = aws_vpc.my_vpc.id
 tags = {
 Name = "my_private_RT2"
 }
}
resource "aws_route_table_association" "private2_RT2_assoc" {
 subnet_id = aws_subnet.my_private_subnet2.id
 route_table_id = aws_route_table.my_private_RT2.id
}
# private_RT4
resource "aws_route_table_association" "private4_RT2_assoc" {
 subnet_id = aws_subnet.my_private_subnet4.id
 route_table_id = aws_route_table.my_private_RT2.id
}