terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  s3_use_path_style           = true

  endpoints {
    iam = "http://127.0.0.1:4566"
    s3  = "http://127.0.0.1:4566"
    ec2 = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }

  default_tags {
    tags = {
      Environment = var.environement
    }
  }
}
resource "random_pet" "this" {}

resource "aws_iam_user" "lb" {
  count = 3
  name  = "${random_pet.this.id}-${var.org-name}-${count.index}"
}

# This policy must be associated with all IAM users created through this code.

resource "aws_iam_user_policy" "lb_ro" {
  name = "ec2-describe-policy"
  user = aws_iam_user.lb.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_s3_bucket" "example" {
  for_each = var.s3_buckets
  bucket   = "${random_pet.this.id}-${each.value}"
}

resource "aws_s3_object" "object" {
  for_each = var.s3_buckets
  bucket   = aws_s3_bucket.example[each.key].id
  key      = var.s3_base_object
}

resource "aws_security_group" "example" {
  name = var.sg_name
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.example.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}
