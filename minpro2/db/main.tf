resource "aws_vpc" "bsd_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "bsd_vpc"
    }
}

resource "aws_subnet" "bsd_public_subnet1" {
    vpc_id = aws_vpc.bsd_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = var.availability_zone1
    map_public_ip_on_launch = true
    tags = {
        Name = "bsd_public_subnet1"
    }
}
resource "aws_subnet" "bsd_private_subnet1" {
    vpc_id = aws_vpc.bsd_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = var.availability_zone1
    tags = {
        Name = "bsd_private_subnet1"
    }
}
resource "aws_subnet" "bsd_private_subnet2" {
    vpc_id = aws_vpc.bsd_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = var.availability_zone1
    tags = {
        Name = "bsd_private_subnet2"
    }
}
# Subnet 생성(availability_zone2)
resource "aws_subnet" "bsd_public_subnet2" {
    vpc_id = aws_vpc.bsd_vpc.id
    cidr_block = "10.0.101.0/24"
    availability_zone = var.availability_zone2
    map_public_ip_on_launch = true
    tags = {
        ame = "bsd_public_subnet2"
    }
}
resource "aws_subnet" "bsd_private_subnet3" {
    vpc_id = aws_vpc.bsd_vpc.id
    cidr_block = "10.0.102.0/24"
    availability_zone = var.availability_zone2
    tags = {
        Name = "bsd_private_subnet3"
    }
}
resource "aws_subnet" "bsd_private_subnet4" {
    vpc_id = aws_vpc.bsd_vpc.id
    cidr_block = "10.0.103.0/24"
    availability_zone = var.availability_zone2
    tags = {
        Name = "bsd_private_subnet4"
    }
}
# Internet Gateway 생성
resource "aws_internet_gateway" "bsd_IGW" {
    vpc_id = aws_vpc.bsd_vpc.id
    tags = {
        Name = "bsd_IGW"
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
resource "aws_nat_gateway" "bsd_NATGW" {
    allocation_id = aws_eip.NAT_EIP.id
    subnet_id = aws_subnet.bsd_public_subnet1.id
    tags = {
        Name = "bsd_NATGW"
    }
    depends_on = [aws_internet_gateway.bsd_IGW]
}
# 라우팅 테이블 설정 & 라우팅 테이블 - 서브넷 연결
# public_RT1
resource "aws_route_table" "bsd_public_RT" {
    vpc_id = aws_vpc.bsd_vpc.id
    route {
    cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.bsd_IGW.id
    }
    tags = {
        Name = "bsd_public_RT"
    }
}
resource "aws_route_table_association" "public_RT1_assoc" {
    subnet_id = aws_subnet.bsd_public_subnet1.id
    route_table_id = aws_route_table.bsd_public_RT.id
}
# public_RT2
resource "aws_route_table_association" "public_RT2_assoc" {
    subnet_id = aws_subnet.bsd_public_subnet2.id
    route_table_id = aws_route_table.bsd_public_RT.id
}
# private_RT1
resource "aws_route_table" "bsd_private_RT1" {
    vpc_id = aws_vpc.bsd_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.bsd_NATGW.id
    }
    tags = {
        Name = "bsd_private_RT1"
    }
}
resource "aws_route_table_association" "private1_RT1_assoc" {
    subnet_id = aws_subnet.bsd_private_subnet1.id
    route_table_id = aws_route_table.bsd_private_RT1.id
}
# vi database/variables.tf
# private_RT2
resource "aws_route_table_association" "private3_RT1_assoc" {
    subnet_id = aws_subnet.bsd_private_subnet3.id
    route_table_id = aws_route_table.bsd_private_RT1.id
}
# private_RT3
resource "aws_route_table" "bsd_private_RT2" {
    vpc_id = aws_vpc.bsd_vpc.id
    tags = {
        Name = "bsd_private_RT2"
    }
}
resource "aws_route_table_association" "private2_RT2_assoc" {
    subnet_id = aws_subnet.bsd_private_subnet2.id
    route_table_id = aws_route_table.bsd_private_RT2.id
}
# private_RT4
resource "aws_route_table_association" "private4_RT2_assoc" {
    subnet_id = aws_subnet.bsd_private_subnet4.id
    route_table_id = aws_route_table.bsd_private_RT2.id
}

# rds DB 클러스터 생성
resource "aws_rds_cluster" "default" {
    cluster_identifier = "bsd-aurora-cluster"
    engine = "aurora-bsdsql"
    availability_zones = [var.availability_zone1, var.availability_zone2]
    db_subnet_group_name = aws_db_subnet_group.default.name
    database_name = var.db_name
    master_username = var.db_username
    master_password = var.db_password
    vpc_security_group_ids = [aws_security_group.bsddb_SG.id]
    skip_final_snapshot = true
}
# rds cluster_instance 생성
resource "aws_rds_cluster_instance" "cluster_instances1" {
    identifier = "aurora-cluster-instance-1"
    cluster_identifier = aws_rds_cluster.default.id
    instance_class = "db.t2.small"
    engine = aws_rds_cluster.default.engine
    engine_version = aws_rds_cluster.default.engine_version
}
resource "aws_rds_cluster_instance" "cluster_instances2" {
    identifier = "aurora-cluster-instance-2"
    cluster_identifier = aws_rds_cluster.default.id
    instance_class = "db.t2.small"
    engine = aws_rds_cluster.default.engine
    engine_version = aws_rds_cluster.default.engine_version
}
# vi database/variables.tf
resource "aws_db_subnet_group" "default" {
    name = "main"
    subnet_ids = [aws_subnet.bsd_private_subnet2.id, aws_subnet.bsd_private_subnet4.id]
    tags = {
        Name = "bsd DB subnet group"
    }
}
#db_보안그룹 생성
resource "aws_security_group" "bsddb_SG" {
    name = "bsddb_SG"
    description = "Allow 3306/tcp"
    vpc_id = aws_vpc.bsd_vpc.id
    ingress {
        description = "Allow 3306/tcp"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }  
    tags = {
        Name = "bsddb_SG"
    }
}