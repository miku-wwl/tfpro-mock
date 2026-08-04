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
    ec2 = "http://127.0.0.1:4566"
    iam = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
    s3  = "http://127.0.0.1:4566"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "challenge-5-tfstate"
    key    = "vpc.tfstate"

    region                      = "us-east-1"
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    use_path_style            = true

    endpoints = {
      s3 = "http://127.0.0.1:4566"
    }
  }
}

module "ec2" {
  source = "../../modules/ec2"
  ids = data.terraform_remote_state.vpc.outputs.subnet_ids
}

module "sg" {
  source = "../../modules/sg"
  id =  data.terraform_remote_state.vpc.outputs.vpc_id
}

import {
  id = "subnet-397a2fba4af14b368"
  to = module.ec2.aws_instance.ec2["subnet-397a2fba4af14b368"]
}

import {
  id = "subnet-948bbcf88c35df585"
  to = module.ec2.aws_instance.ec2["subnet-948bbcf88c35df585"]
}

import {
  id = "sg-1be91260f83ff09eb"
  to = module.sg.aws_security_group.sg["app-1-sg"]
}

import {
  id = "sg-9c756e8a7dacac06a"
  to = module.sg.aws_security_group.sg["app-2-sg"]
}

import {
  id = "sgr-b3a5c7f18eba851bf"
  to = module.sg.aws_vpc_security_group_egress_rule.name["sg02-out-tcp-0.0.0.0/0-app-2-8443"]
}

import {
  id = "sgr-dea30d4cfc70c2686"
  to = module.sg.aws_vpc_security_group_egress_rule.name["sg02-out-tcp-0.0.0.0/0-app-2-9000"]
}

import {
  id = "sgr-e64081e860d74c1b7"
  to = module.sg.aws_vpc_security_group_ingress_rule.name["sg01-in-tcp-0.0.0.0/0-app-1-80"]
}

import {
  id = "sgr-1b4e3763b0613cce6"
  to = module.sg.aws_vpc_security_group_ingress_rule.name["sg01-in-tcp-10.77.0.0/16-app-1-443"]
}