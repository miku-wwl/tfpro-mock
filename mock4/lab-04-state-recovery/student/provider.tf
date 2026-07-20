provider "aws" {
  region                      = "us-west-2"
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://127.0.0.1:4567"
    iam = "http://127.0.0.1:4567"
    s3  = "http://127.0.0.1:4567"
    sts = "http://127.0.0.1:4567"
  }

  default_tags {
    tags = {
      Environment = "exam"
      ManagedBy   = "terraform"
    }
  }
}
