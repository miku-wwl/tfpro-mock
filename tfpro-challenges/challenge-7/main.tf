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

output "list_amis" {
  value = [for instance in local.ec2_data : instance.AMI_ID]
}
