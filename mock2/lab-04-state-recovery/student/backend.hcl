bucket = "tfpro-sim"
key    = "tfpro-sim/lab-04/terraform.tfstate"
region = "us-west-2"
endpoints = {
  s3 = "http://localhost:4566"
}
use_path_style = true
skip_credentials_validation = true
skip_metadata_api_check = true
skip_requesting_account_id = true
skip_region_validation = true
