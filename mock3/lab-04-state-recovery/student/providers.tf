# No default AWS provider is intentionally declared. Every AWS object must use
# the provider alias required by the exercise.
provider "aws" {
  alias                       = "storage"
  region                      = "us-west-2" # intentionally wrong for this lab
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = var.localstack_endpoint
    sts = var.localstack_endpoint
  }
}

provider "aws" {
  alias                       = "identity"
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    iam = var.localstack_endpoint
    sts = var.localstack_endpoint
  }
}

provider "aws" {
  alias                       = "network"
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = var.localstack_endpoint
    sts = var.localstack_endpoint
  }
}

provider "aws" {
  alias                       = "readonly"
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    sts = var.localstack_endpoint
  }
}

data "aws_caller_identity" "readonly" {
  provider = aws.readonly
}
