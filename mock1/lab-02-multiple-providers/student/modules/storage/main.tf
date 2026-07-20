terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70.0"
    }
  }
}

variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "archive" {
  bucket = var.bucket_name
}

output "bucket_name" {
  value = aws_s3_bucket.archive.id
}
