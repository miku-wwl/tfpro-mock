locals {
  localstack_endpoint = "http://localhost:4566"
}

# BUG: provider blocks do not support dynamic for_each aliases.
provider "aws" {
  for_each = local.profile_matrix

  alias                       = each.key
  profile                     = each.value.profile_name
  region                      = each.value.region
  shared_config_files         = ["${path.module}/aws/config"]
  shared_credentials_files    = ["${path.module}/.aws/credentials.local"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    autoscaling = local.localstack_endpoint
    ec2         = local.localstack_endpoint
    iam         = local.localstack_endpoint
    s3          = local.localstack_endpoint
    sts         = local.localstack_endpoint
  }
}
