terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
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
    autoscaling = "http://localhost:4566"
    ec2         = "http://localhost:4566"
    iam         = "http://localhost:4566"
    sts         = "http://localhost:4566"
  }
}


module "asg" {
  source = "./modules/asg"
}

module "iam" {
  source = "./modules/iam"
}

data "aws_caller_identity" "local" {}

resource "local_file" "this" {
  content  = data.aws_caller_identity.local.account_id
  filename = "account-number.txt"
}
