terraform {
  required_version = ">= 1.11.0, < 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.74.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  profile                     = "compute_operator"
  shared_config_files         = ["${path.module}/../aws/config"]
  shared_credentials_files    = ["${path.module}/../.aws/credentials.txt"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3  = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "audit_archive" {
  bucket = "tfpro-lab02-audit-archive"

  lifecycle {
    prevent_destroy = true
  }
}
