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
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

provider "aws" {
  alias   = "readonly"
  region  = "us-east-1"
  profile = "readonly-access"

  shared_config_files = [
    "${path.module}/.aws/config"
  ]

  shared_credentials_files = [
    "${path.module}/base-folder/default-creds.txt"
  ]

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
  alias   = "iam"
  region  = "us-east-1"
  profile = "iam-access"

  shared_config_files      = ["${path.module}/.aws/config"]
  shared_credentials_files = ["${path.module}/.aws/credentials"]

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
  alias   = "ec2"
  region  = "us-east-1"
  profile = "ec2-access"

  shared_config_files      = ["${path.module}/.aws/config"]
  shared_credentials_files = ["${path.module}/.aws/credentials"]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

resource "aws_security_group" "allow_tls" {
  provider = aws.ec2
  name     = "demo-firewall"

}

data "aws_caller_identity" "current" {
  provider = aws.readonly
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}


resource "aws_iam_role" "cw_full_access" {
  provider = aws.iam
  name     = "CloudWatchFullAccess"

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

resource "aws_iam_role_policy_attachment" "cw_full_access" {
  provider   = aws.iam
  role       = aws_iam_role.cw_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
