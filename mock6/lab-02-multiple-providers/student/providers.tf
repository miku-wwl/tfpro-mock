provider "aws" {
  profile = "readonly-auditor"

  region                      = "us-east-1"
  shared_config_files         = ["${path.module}/.aws/config.backup"]
  shared_credentials_files    = ["${path.module}/.aws/credentials.local"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
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
  profile = "compute-admin"

  region                      = "us-east-1"
  shared_config_files         = ["${path.module}/.aws/config.backup"]
  shared_credentials_files    = ["${path.module}/.aws/credentials.local"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
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
  profile = "identity-admin"

  region                      = "us-east-1"
  shared_config_files         = ["${path.module}/.aws/config.backup"]
  shared_credentials_files    = ["${path.module}/.aws/credentials.local"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  s3_use_path_style           = true

  endpoints {
    autoscaling = "http://localhost:4566"
    ec2         = "http://localhost:4566"
    iam         = "http://localhost:4566"
    s3          = "http://localhost:4566"
    sts         = "http://localhost:4566"
  }
}
