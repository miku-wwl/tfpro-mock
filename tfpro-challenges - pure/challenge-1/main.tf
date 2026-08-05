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
  count = 3
  name = "ec2-describe-policy"
  user = aws_iam_user.lb[count.index].name
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
  for_each = toset(var.s3_buckets)
  bucket   = "${random_pet.this.id}-${each.value}"
}

resource "aws_s3_object" "object" {
  for_each = toset(var.s3_buckets)
  bucket   = aws_s3_bucket.example[each.key].id
  key      = var.s3_base_object
}

output "s3_buckets" {
  value = [for k,v in aws_s3_bucket.example: v.bucket]
}

output "user_names" {
  value = aws_iam_user.lb.*.name
}

resource "local_file" "s3" {
  filename = "${path.module}/s3.txt"
  content = jsonencode([for k,v in aws_s3_bucket.example: v.bucket])  
}

resource "local_file" "iam" {
  filename = "${path.module}/iam-users.txt"
  content = jsonencode(aws_iam_user.lb.*.name)
}

import {
  id = "loved-humpback-kplabs-0"
  to = aws_iam_user.lb[0]
}

import {
  id = "loved-humpback-kplabs-1"
  to = aws_iam_user.lb[1]
}

import {
  id = "loved-humpback-kplabs-2"
  to = aws_iam_user.lb[2]
}

import {
  id = "loved-humpback-kplabs-0:ec2-describe-policy"
  to = aws_iam_user_policy.lb_ro[0]
}

import {
  id = "loved-humpback-kplabs-1:ec2-describe-policy"
  to = aws_iam_user_policy.lb_ro[1]
}

import {
  id = "loved-humpback-kplabs-2:ec2-describe-policy"
  to = aws_iam_user_policy.lb_ro[2]
}

import {
  id = "loved-humpback-kplabs-1"
  to = aws_s3_bucket.example["kplabs-1"]
}

import {
  id = "loved-humpback-kplabs-2"
  to = aws_s3_bucket.example["kplabs-2"]
}

import {
  id = "loved-humpback-kplabs-1/base.txt"
  to = aws_s3_object.object["kplabs-1"]
}

import {
  id = "loved-humpback-kplabs-2/base.txt"
  to = aws_s3_object.object["kplabs-2"]
}