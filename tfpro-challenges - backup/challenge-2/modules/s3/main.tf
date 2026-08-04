terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}

resource "aws_s3_bucket" "example" {
  for_each = var.s3_buckets
  # bucket   = "${random_pet.this.id}-${each.value}"
  bucket   = "${var.id}-${each.value}"
}

resource "aws_s3_object" "object" {
  for_each = var.s3_buckets
  bucket   = aws_s3_bucket.example[each.key].id
  key      = var.s3_base_object
}

