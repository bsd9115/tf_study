# Configure AMI Data Source
data "aws_ami" "server-ami" {
  most_recent = true
  # 소유자 계정 ID
  owners = ["631665235780"]   

  filter {
    # AMI 이름
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}