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

  endpoints {
    ec2 = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket                      = "challenge-5-terraform-state"
    key                         = "vpc.tfstate"
    region                      = "us-east-1"
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints = {
      s3 = "http://localhost:4566"
    }
  }
}

locals {
  sg_rules = csvdecode(file("${path.root}/../../base-folder/sg.csv"))

  app_1_ingress = {
    for index, rule in local.sg_rules : index => rule
    if rule.description == "app-1" && rule.direction == "in"
  }

  app_2_egress = {
    for index, rule in local.sg_rules : index => rule
    if rule.description == "app-2" && rule.direction == "out"
  }
}

module "ec2" {
  source     = "../../modules/ec2"
  subnet_ids = data.terraform_remote_state.vpc.outputs.subnet_ids
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  rules = {
    ingress = local.app_1_ingress
    egress  = local.app_2_egress
  }
}
