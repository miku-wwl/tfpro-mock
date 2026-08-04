terraform {
  required_version = "= 1.14.0"

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

module "ec2" {
  source = "./modules/ec2"

  name = module.iam.name
}

module "sg" {
  source = "./modules/sg"

  sg_name = var.sg_name
}

module "s3" {
  source = "./modules/s3"

  s3_buckets = var.s3_buckets
  s3_base_object = var.s3_base_object
  id = module.random.id
}

module "iam" {
  source = "./modules/iam"

  org-name = var.org-name
  id = module.random.id
}

module "random" {
  source = "./modules/random"
}