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
  }
}

module "ec2" {
  source = "../../modules/ec2"
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}

module "sg" {
  source = "../../modules/sg"
}