locals {
  localstack_endpoint = "http://localhost:4566"
}

provider "aws" {
  alias                       = "compute"
  profile                     = local.profile_matrix.compute.profile_name
  region                      = local.profile_matrix.compute.region
  shared_config_files         = ["${path.module}/.aws/config"]
  shared_credentials_files    = ["${path.module}/.aws/credentials"]
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

provider "aws" {
  alias                       = "identity"
  profile                     = local.profile_matrix.identity.profile_name
  region                      = local.profile_matrix.identity.region
  shared_config_files         = ["${path.module}/.aws/config"]
  shared_credentials_files    = ["${path.module}/.aws/credentials"]
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

provider "aws" {
  alias                       = "readonly"
  profile                     = local.profile_matrix.audit.profile_name
  region                      = local.profile_matrix.audit.region
  shared_config_files         = ["${path.module}/.aws/config"]
  shared_credentials_files    = ["${path.module}/.aws/credentials"]
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
