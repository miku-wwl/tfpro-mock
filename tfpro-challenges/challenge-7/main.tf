terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}

provider "local" {}

locals {
  ec2_data = csvdecode(file("${path.module}/ec2.csv"))
}
