terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://127.0.0.1:4566"
    iam = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}

locals {
  ec2_csv = csvdecode(file("${path.module}/ec2.csv"))
}

output "list_amis" {
  value = [for k, v in local.ec2_csv : v.AMI_ID]
}

output "unique_team_names" {
  value = distinct([for k, v in local.ec2_csv : v.Team_Name])
}

output "regions_list_of_lists" {
  value = [for k, v in local.ec2_csv : [
    v.Region
  ]]
}

output "list_list_condition" {
  value = distinct([for k, v in local.ec2_csv : [
    v.Region
  ]])
}

locals {
  dist_instance_type = distinct([for k, v in local.ec2_csv : v.instance_type])
}

output "instance_count_by_type" {
  value = {
    for k, v in local.dist_instance_type : v => length(
      [for kk, vv in local.ec2_csv : vv if v == vv.instance_type]
    )
  }
}

output "instance_details" {
  value = [
    for k, v in local.ec2_csv : {
      team = v.Team_Name
      type = v.instance_type
    }
  ]
}

output "map_of_maps" {
  value = {
    for k, v in local.ec2_csv : "${v.instance_type}_${v.Region}_${v.Team_Name}" => {
      "ami_id"        = v.AMI_ID
      "instance_type" = v.instance_type
      "region"        = v.Region
      "team_name"     = v.Team_Name
    }
  }
}