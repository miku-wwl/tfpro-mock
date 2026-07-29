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

output "unique_team_names" {
  value = distinct([for instance in local.ec2_data : instance.Team_Name])
}

output "regions_list_of_lists" {
  value = [for instance in local.ec2_data : [instance.Region]]
}
