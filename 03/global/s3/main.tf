provider "aws" {
  region = "us-east-2"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "terraform_state" {

  # 버킷 값은 유일한 이름을 지정해야 한다.
  bucket = "bucket-9115-0819"
  
  # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle
  # Allow S3 bucket Destroy 
  # force_destroy = true

  # 코드 이력을 관리하기 위해 상태 파일의 버전 관리를 활성화 한다.
  versioning {
    enabled = true
  }

  # 서버 측 암호화를 활성화 한다.
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
  tags = {
    Name = "My S3 bucket"
  }

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
# Create Dynamodb
resource "aws_dynamodb_table" "terraform-locks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"    # 값은 S(string), N(number), B(binary) 중 하나이어야 한다.
  }
}