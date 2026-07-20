# Starter trap: the default provider can work with ambient credentials but is not allowed.
provider "aws" {
  region = "us-east-1"

  shared_config_files      = ["${path.root}/.aws-config/config"]
  shared_credentials_files = ["${path.root}/.aws/credentials.localstack"]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    autoscaling = "http://localhost:4566"
    ec2         = "http://localhost:4566"
    iam         = "http://localhost:4566"
    s3          = "http://localhost:4566"
    sts         = "http://localhost:4566"
  }
}

provider "aws" {
  alias   = "compute"
  region  = "us-east-1"
  profile = "compute-runner"

  shared_config_files      = ["${path.root}/.aws-config/config"]
  shared_credentials_files = ["${path.root}/.aws/credentials.localstack"]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    autoscaling = "http://localhost:4566"
    ec2         = "http://localhost:4566"
    iam         = "http://localhost:4566"
    s3          = "http://localhost:4566"
    sts         = "http://localhost:4566"
  }
}

provider "aws" {
  alias   = "identity"
  region  = "us-east-1"
  profile = "identity-operator"

  shared_config_files      = ["${path.root}/.aws-config/config"]
  shared_credentials_files = ["${path.root}/.aws/credentials.localstack"]

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    autoscaling = "http://localhost:4566"
    ec2         = "http://localhost:4566"
    iam         = "http://localhost:4566"
    s3          = "http://localhost:4566"
    sts         = "http://localhost:4566"
  }
}
