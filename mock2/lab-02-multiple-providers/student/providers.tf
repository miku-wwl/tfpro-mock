provider "aws" {
  region                      = var.region
  profile                     = "compute_operator"
  shared_config_files         = ["${path.module}/.aws/conf"]
  shared_credentials_files    = ["${path.module}/.aws/credential"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    autoscaling = var.localstack_endpoint
    ec2         = var.localstack_endpoint
    iam         = var.localstack_endpoint
    s3          = var.localstack_endpoint
    sts         = var.localstack_endpoint
  }
}

provider "aws" {
  alias                       = "compute"
  region                      = var.region
  profile                     = "compute_operator"
  shared_config_files         = ["${path.module}/aws/config"]
  shared_credentials_files    = ["${path.module}/.aws/credentials.txt"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    autoscaling = var.localstack_endpoint
    ec2         = var.localstack_endpoint
    iam         = var.localstack_endpoint
    s3          = var.localstack_endpoint
    sts         = var.localstack_endpoint
  }
}

provider "aws" {
  alias                       = "identity"
  region                      = var.region
  profile                     = "identity_operator"
  shared_config_files         = ["${path.module}/aws/config"]
  shared_credentials_files    = ["${path.module}/.aws/credentials.txt"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    autoscaling = var.localstack_endpoint
    ec2         = var.localstack_endpoint
    iam         = var.localstack_endpoint
    s3          = var.localstack_endpoint
    sts         = var.localstack_endpoint
  }
}
