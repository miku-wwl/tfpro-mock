terraform {
  backend "s3" {
    key                          = "tfpro-sim/lab-01/shared.tfstate"
    region                       = "us-east-1"
    use_path_style               = true
    skip_credentials_validation  = true
    skip_region_validation       = true
    skip_requesting_account_id   = true
    skip_metadata_api_check      = true
  }
}
