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

output "list_list_condition" {
  value = [
    for instance in local.ec2_data : [instance.Region]
    if instance.instance_type == "nano"
  ]
}

output "instance_count_by_type" {
  value = {
    for instance_type in distinct([for instance in local.ec2_data : instance.instance_type]) :
    instance_type => length([
      for instance in local.ec2_data : instance
      if instance.instance_type == instance_type
    ])
  }
}

output "instance_details" {
  value = [
    for instance in local.ec2_data : {
      team = instance.Team_Name
      type = instance.instance_type
    }
  ]
}
