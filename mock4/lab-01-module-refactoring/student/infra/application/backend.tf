terraform {
  backend "s3" {
    bucket                      = "tfpro-lab01-state-nimbus"
    key                         = "REPLACE_WITH_REQUIRED_APPLICATION_KEY"
    region                      = "us-east-1"
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
    endpoints = {
      s3 = "http://localhost:4566"
    }
  }
}
