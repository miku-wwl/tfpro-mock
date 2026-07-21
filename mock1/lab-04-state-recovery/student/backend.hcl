bucket = "tfpro-lab04-tfstate"
key    = "tfpro-sim/lab-04/terraform.tfstaet"
region = "eu-west-1"

access_key                   = "test"
secret_key                   = "test"
skip_credentials_validation = true
skip_metadata_api_check      = true
skip_region_validation       = true
skip_requesting_account_id   = true
skip_s3_checksum             = true
use_path_style               = true

endpoints = {
  s3 = "http://localhost:4576"
}
