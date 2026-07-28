terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
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
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    s3  = "http://localhost:4566"
    sts = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Environment = var.environement
    }
  }
}
module "random" {
  source = "./modules/random"
}

module "iam" {
  source   = "./modules/iam"
  pet_id   = "prompt-jawfish"
  org_name = var.org-name
}

module "s3" {
  source      = "./modules/s3"
  pet_id      = "prompt-jawfish"
  s3_buckets  = var.s3_buckets
  base_object = var.s3_base_object
}

module "sg" {
  source = "./modules/sg"
  name   = var.sg_name
}

module "ec2" {
  source               = "./modules/ec2"
  iam_instance_profile = "test_profile"
}
