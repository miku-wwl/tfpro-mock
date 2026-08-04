terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }

  backend "s3" {
    bucket = "challenge-5-tfstate"
    key    = "vpc.tfstate"

    region                      = "us-east-1"
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    use_path_style           = true

    endpoints = {
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

output "vpc_id" {
  value = module.vpc.id
}

output "subnet_ids" {
  value = module.vpc.subnet_ids
}

import {
  id = "vpc-4856450394f3f71b3"
  to = module.vpc.aws_vpc.main
}

import {
  id = "vpc-94ccced721e90e1db"
  to = module.vpc.aws_vpc.random
}

import {
  id = "subnet-397a2fba4af14b368"
  to = module.vpc.aws_subnet.challenge_5["subnet1"]
}

import {
  id = "subnet-948bbcf88c35df585"
  to = module.vpc.aws_subnet.challenge_5["subnet2"]
}

import {
  id = "subnet-fb2c2008bc165852c"
  to = module.vpc.aws_subnet.random["subnet1"]
}

import {
  id = "subnet-1e6074562649a378d"
  to = module.vpc.aws_subnet.random["subnet2"]
}