provider "aws" {
  alias  = "compute"
  region = var.region

  profile                  = "compute-operator"
  shared_config_files      = ["${path.module}/.aws/config"]
  shared_credentials_files = ["${path.module}/.aws/credentials"]

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  endpoints {
    autoscaling = var.localstack_endpoint
    ec2         = var.localstack_endpoint
    iam         = var.localstack_endpoint
    s3          = var.localstack_endpoint
    sts         = var.localstack_endpoint
  }
}

provider "aws" {
  alias  = "identity"
  region = var.region

  profile                  = "identity-operator"
  shared_config_files      = ["${path.module}/.aws/config"]
  shared_credentials_files = ["${path.module}/.aws/credentials"]

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  endpoints {
    autoscaling = var.localstack_endpoint
    ec2         = var.localstack_endpoint
    iam         = var.localstack_endpoint
    s3          = var.localstack_endpoint
    sts         = var.localstack_endpoint
  }
}

provider "aws" {
  alias  = "readonly"
  region = var.region

  profile                  = "readonly-auditor"
  shared_config_files      = ["${path.module}/.aws/config"]
  shared_credentials_files = ["${path.module}/.aws/credentials"]

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  endpoints {
    autoscaling = var.localstack_endpoint
    ec2         = var.localstack_endpoint
    iam         = var.localstack_endpoint
    s3          = var.localstack_endpoint
    sts         = var.localstack_endpoint
  }
}
