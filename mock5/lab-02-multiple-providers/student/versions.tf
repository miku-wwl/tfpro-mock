terraform {
  required_version = ">= 1.11.0, < 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
  }

  backend "s3" {
    bucket = "tfpro-lab02-state"
    key    = "set-05/lab-02/terraform.tfstate"
    region = "us-east-1"

    access_key = "test"
    secret_key = "test"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true

    endpoints = {
      s3 = "http://localhost:4566"
    }
  }
}
