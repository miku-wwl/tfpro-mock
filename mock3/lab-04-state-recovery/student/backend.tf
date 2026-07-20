terraform {
  backend "s3" {
    bucket = "RENDERED-BY-SETUP"
    key    = "tfpro-sim/lab-04/terraform.tfstates"
    region = "us-west-2"

    endpoints = {
      s3 = "http://localhost:4567"
    }

    access_key                  = "test"
    secret_key                  = "test"
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
}
