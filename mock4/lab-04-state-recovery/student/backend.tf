terraform {
  backend "s3" {
    key    = "tfpro-sim/lab04/terraform.tfstate"
    region = "us-west-2"

    endpoints = {
      s3 = "http://127.0.0.1:4567"
    }

    use_path_style              = false
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
}
