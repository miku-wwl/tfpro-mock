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
  alias                       = "asg"
  profile                     = "asg"
  shared_config_files         = ["${path.module}/.aws/conf"]
  shared_credentials_files    = ["${path.module}/.aws/credentials"]
  region                      = "us-east-1"
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

provider "aws" {
  alias                       = "iam"
  profile                     = "iam"
  shared_config_files         = ["${path.module}/.aws/conf"]
  shared_credentials_files    = ["${path.module}/.aws/credentials"]
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  endpoints {
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
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

provider "aws" {
  alias                       = "readonly"
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
  }

  assume_role {
    role_arn = "arn:aws:iam::000000000000:role/ReadOnlyRole"
  }
}


module "asg" {
  source    = "./modules/asg"
  providers = { aws = aws.asg }
}

module "iam" {
  source    = "./modules/iam"
  providers = { aws = aws.iam }
}

data "aws_caller_identity" "local" {
  provider = aws.readonly
}

resource "local_file" "this" {
  content  = data.aws_caller_identity.local.account_id
  filename = "account-number.txt"
}
