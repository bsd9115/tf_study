# VPC
resource "aws_vpc" "My-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "My-vpc"
    }
}
# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "My-IGW" {
    vpc_id = aws_vpc.My-vpc.id
    tags = {
        Name = "My-IGW"
    }
}
# 퍼블릭 서브넷 생성
resource "aws_subnet" "My-Pub-sub01" {
    vpc_id = aws_vpc.My-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "My-Public-subnet-01"
    }
}
# 퍼블릭 서브넷 생성
resource "aws_subnet" "My-Pub-sub02" {
    vpc_id = aws_vpc.My-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-northeast-2c"
    tags = {
        Name = "My-Public-subnet-02"
    }
}
# 프라이빗 서브넷 생성(인스턴스 위치)
resource "aws_subnet" "My-Private-sub01" {
    vpc_id = aws_vpc.My-vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "My-Private-subnet-01"
    }
}
# 프라이빗 서브넷 생성(인스턴스 위치)
resource "aws_subnet" "My-Private-sub02" {
    vpc_id = aws_vpc.My-vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "ap-northeast-2c"
    tags = {
        Name = "My-Private-subnet-02"
    }
}
# 프라이빗 서브넷 생성(데이터베이스 위치)
resource "aws_subnet" "My-Private-RDS-sub01" {
    vpc_id = aws_vpc.My-vpc.id
    cidr_block = "10.0.5.0/24"
    availability_zone = "ap-northeast-2a"
    tags = {
        Name = "My-Private-RDS-subnet-01"
    }
}
# 프라이빗 서브넷 생성(데이터베이스 위치)
resource "aws_subnet" "My-Private-RDS-sub02" {
    vpc_id = aws_vpc.My-vpc.id
    cidr_block = "10.0.6.0/24"
    availability_zone = "ap-northeast-2c"
    tags = {
        Name = "My-Private-RDS-subnet-02"
    }  
}
# 퍼블릭 서브넷 라우팅 테이블 생성
resource "aws_route_table" "MyPublicRTB" {
    vpc_id = aws_vpc.My-vpc.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My-IGW.id
    }
    tags = {
        Name = "My-Public-RTB"
    }
}
# 프라이빗 서브넷 라우팅 테이블 생성
resource "aws_route_table" "MyPrivateRTB" {
    vpc_id = aws_vpc.My-vpc.id
    tags = {
        Name = "My-Private-RTB"
    }
}
# 퍼블릭 서브넷 라우팅 테이블 연결1
resource "aws_route_table_association" "MyPublicRTBassociation01" {
    subnet_id = aws_subnet.My-Pub-sub01.id
    route_table_id = aws_route_table.MyPublicRTB.id
}
# 퍼블릭 서브넷 라우팅 테이블 연결2
resource "aws_route_table_association" "MyPublicRTBassociation02" {
    subnet_id = aws_subnet.My-Pub-sub02.id
    route_table_id = aws_route_table.MyPublicRTB.id
}
# 프라이빗 서브넷 라우팅 테이블 연결1
resource "aws_route_table_association" "MyPrivateRTBassociation01" {
    subnet_id = aws_subnet.My-Private-sub01.id
    route_table_id = aws_route_table.MyPrivateRTB.id
}
# 프라이빗 서브넷 라우팅 테이블 연결2
resource "aws_route_table_association" "MyPrivateRTBassociation02" {
    subnet_id = aws_subnet.My-Private-sub02.id
    route_table_id = aws_route_table.MyPrivateRTB.id
}
# 프라이빗 서브넷 라우팅 테이블 연결3
resource "aws_route_table_association" "MyPrivateRDSRTBassociation01" {
    subnet_id = aws_subnet.My-Private-RDS-sub01.id
    route_table_id = aws_route_table.MyPrivateRTB.id
}
# 프라이빗 서브넷 라우팅 테이블 연결4
resource "aws_route_table_association" "MyPrivateRDSRTBassociation02" {
    subnet_id = aws_subnet.My-Private-RDS-sub02.id
    route_table_id = aws_route_table.MyPrivateRTB.id
}
# 보안그룹 생성(EC2 인스턴스, 데이터베이스)
resource "aws_security_group" "myInstanceSG" {
    name = "myInstanceSG"
    description = "Allow HTTP(80/tcp)"
    vpc_id = aws_vpc.My-vpc.id
    ingress {
        description = "HTTP(8080/tcp)"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow HTTP(80/tcp)"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH(22/tcp)"
        from_port = 22
        to_port = 22
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
        Name = "MyInstanceSG"
    }
}
resource "aws_security_group" "myALB-SG" {
    name = "myALB-SG"
    description = "Allow HTTP(80/tcp)"
    vpc_id = aws_vpc.My-vpc.id
    ingress {
        description = "Allow HTTP(80/tcp)"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-01"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "myALB-SG"
    }
}


# 시작 구성 설정
resource "aws_launch_configuration" "My-laucnch-conf" {
    image_id = "ami-039c6ebab2112da43"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.myInstanceSG.id]
    user_data = <<-EOF
                #!/bin/bash
# DB 인스턴스에 대한 정보(index.php 파일에 include해서 사용)
    echo "<?php
    define('DB_SERVER','my-database.cluster-cbetrbqprzbw.ap-northeast-2.rds.amazonaws.com');
 define('DB_USERNAME', 'admin');
 define('DB_PASSWORD', '12345678');
 define('DB_DATABASE', 'inventory');
 ?>" > /var/www/inc/dbinfo.inc
EOF
 lifecycle {
 create_before_destroy = true
 }
}
# 오토 스케일링 그룹 생성
resource "aws_autoscaling_group" "My-AG" {
 launch_configuration = aws_launch_configuration.My-laucnch-conf.name
 vpc_zone_identifier = [aws_subnet.My-Private-sub01.id,
aws_subnet.My-Private-sub02.id]
 min_size = 2
 max_size = 10
 health_check_type = "ELB"
 target_group_arns = [aws_lb_target_group.myALB-TG.arn]
 tag {
 key = "Name"
 value = "terraform-asg-example"
 propagate_at_launch = true
 }
}