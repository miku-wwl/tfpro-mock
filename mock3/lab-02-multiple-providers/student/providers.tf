# This default provider can contact LocalStack, but using it bypasses the
# identity boundaries required by the lab.
provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
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
  alias  = "compute"
  region = var.region

  profile                  = "compute-admin"
  shared_config_files      = ["${path.module}/aws/config"]
  shared_credentials_files = ["${path.module}/.aws/credentials.txt"]

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
  shared_config_files      = ["${path.module}/aws/config"]
  shared_credentials_files = ["${path.module}/.aws/credentials.txt"]

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
