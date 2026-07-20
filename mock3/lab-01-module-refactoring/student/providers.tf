locals {
  localstack_endpoint = "http://localhost:4566"
  shared_config_path  = "${path.module}/.aws/config"
  shared_creds_path   = "${path.module}/.aws/credentials"
}

# This inherited default provider is intentionally high privilege. Active legacy
# resources use explicit aliases. A refactoring that silently falls back to this
# provider may run but violates the lab identity contract.
provider "aws" {
  region                   = "us-east-1"
  profile                  = "workload-admin"
  shared_config_files      = [local.shared_config_path]
  shared_credentials_files = [local.shared_creds_path]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = local.localstack_endpoint
    iam = local.localstack_endpoint
    s3  = local.localstack_endpoint
    sts = local.localstack_endpoint
  }
}

provider "aws" {
  alias                    = "network"
  region                   = "us-east-1"
  profile                  = "fabric-admin"
  shared_config_files      = [local.shared_config_path]
  shared_credentials_files = [local.shared_creds_path]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = local.localstack_endpoint
    iam = local.localstack_endpoint
    s3  = local.localstack_endpoint
    sts = local.localstack_endpoint
  }
}

provider "aws" {
  alias                    = "workload"
  region                   = "us-east-1"
  profile                  = "workload-admin"
  shared_config_files      = [local.shared_config_path]
  shared_credentials_files = [local.shared_creds_path]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = local.localstack_endpoint
    iam = local.localstack_endpoint
    s3  = local.localstack_endpoint
    sts = local.localstack_endpoint
  }
}

provider "aws" {
  alias                    = "archive"
  region                   = var.archive.region
  profile                  = "archive-admin"
  shared_config_files      = [local.shared_config_path]
  shared_credentials_files = [local.shared_creds_path]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = local.localstack_endpoint
    iam = local.localstack_endpoint
    s3  = local.localstack_endpoint
    sts = local.localstack_endpoint
  }
}

provider "aws" {
  alias                    = "readonly"
  region                   = "us-east-1"
  profile                  = "observer"
  shared_config_files      = [local.shared_config_path]
  shared_credentials_files = [local.shared_creds_path]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = local.localstack_endpoint
    iam = local.localstack_endpoint
    s3  = local.localstack_endpoint
    sts = local.localstack_endpoint
  }
}
