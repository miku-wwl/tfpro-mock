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
  }
}

provider "aws" {
  profile                  = "iam-access"
  alias                    = "iam"
  shared_config_files      = ["${path.module}/.aws/config"]
  shared_credentials_files = ["${path.module}/.aws/credentials"]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://127.0.0.1:4566"
    iam = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}


provider "aws" {
  profile                     = "ec2-access"
  alias                       = "ec2"
  shared_config_files         = ["${path.module}/.aws/config"]
  shared_credentials_files    = ["${path.module}/.aws/credentials"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://127.0.0.1:4566"
    iam = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}

provider "aws" {
  profile                     = "readonly-access"
  alias                       = "read"
  region                      = "us-east-1"
  shared_config_files         = ["${path.module}/.aws/config"]
  access_key                  = "LKIAQAAAAAAAHZSHHDNT"
  secret_key                  = "7A3r0m45i+uAi9sJTh3kxHKPIoWZpUD/qB5SzKto"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://127.0.0.1:4566"
    iam = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}

resource "aws_security_group" "allow_tls" {
  provider = aws.ec2
  name     = "demo-firewall"
}

data "aws_caller_identity" "current" {
  provider = aws.read
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}


resource "aws_iam_role" "cw_full_access" {
  provider            = aws.iam
  name                = "CloudWatchFullAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_full_access_policy_attachment" {
  role       = aws_iam_role.cw_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}