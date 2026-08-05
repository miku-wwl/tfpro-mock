terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }

  backend "s3" {
    bucket                      = "challenge-5-terraform-state"
    key                         = "vpc.tfstate"
    region                      = "us-east-1"
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    use_path_style              = true

    endpoints = {
      ec2 = "http://127.0.0.1:4566"
      iam = "http://127.0.0.1:4566"
      sts = "http://127.0.0.1:4566"
      s3  = "http://127.0.0.1:4566"
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
    ec2 = "http://127.0.0.1:4566"
    iam = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
    s3  = "http://127.0.0.1:4566"
  }
}

module "vpc" {
  source = "../../modules/vpc"
}

output "ids" {
  value = module.vpc.ids
}

import {
  id = "vpc-598d13bace9383997"
  to = module.vpc.aws_vpc.main
}

import {
  id = "vpc-28b6788ec8302cfb2"
  to = module.vpc.aws_vpc.random
}

import {
  id = "subnet-10f41113436427ba5"
  to = module.vpc.aws_subnet.challenge_5["subnet1"]
}

import {
  id = "subnet-4bbd58bee93a878dd"
  to = module.vpc.aws_subnet.challenge_5["subnet2"]
}

import {
  id = "subnet-9e86917a30f542e51"
  to = module.vpc.aws_subnet.random["subnet1"]
}

import {
  id = "subnet-5c17b1d89b1162207"
  to = module.vpc.aws_subnet.random["subnet2"]
}