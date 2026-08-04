terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}

provider "aws" {
  alias = "asg"
  profile = "asg"
  shared_config_files = ["./.aws/conf"]
  shared_credentials_files = ["./.aws/credentials"]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    iam         = "http://127.0.0.1:4566"
    ec2         = "http://127.0.0.1:4566"
    sts         = "http://127.0.0.1:4566"
    autoscaling = "http://127.0.0.1:4566"
  }
}

provider "aws" {
  alias = "iam"
  profile = "iam"
  shared_config_files = ["./.aws/conf"]
  shared_credentials_files = ["./.aws/credentials"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    iam         = "http://127.0.0.1:4566"
    ec2         = "http://127.0.0.1:4566"
    sts         = "http://127.0.0.1:4566"
    autoscaling = "http://127.0.0.1:4566"
  }
}

provider "aws" {
  alias = "read"
  profile = "read"
  shared_config_files = ["./.aws/conf"]
  shared_credentials_files = ["./.aws/credentials"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    iam         = "http://127.0.0.1:4566"
    ec2         = "http://127.0.0.1:4566"
    sts         = "http://127.0.0.1:4566"
    autoscaling = "http://127.0.0.1:4566"
  }
}

module "asg" {
  source = "./modules/asg"

  providers = {
    aws = aws.asg
  }
}

module "iam" {
  source = "./modules/iam"

  providers = {
    aws = aws.iam
  }
}

data "aws_caller_identity" "local" {
  provider = aws.read
}

resource "local_file" "this" {
  content = data.aws_caller_identity.local.account_id
  filename = "account-number.txt"
}
