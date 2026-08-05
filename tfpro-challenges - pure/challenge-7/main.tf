locals {
  ec2_csv       = csvdecode(file("${path.module}/ec2.csv"))
  distinct_type = distinct([for k, v in local.ec2_csv : v.instance_type])
}

output "list_amis" {
  value = local.ec2_csv.*.AMI_ID
}

output "unique_team_names" {
  value = distinct(local.ec2_csv.*.Team_Name)
}

output "regions_list_of_lists" {
  value = [
    for k, v in local.ec2_csv : [v.Region]
  ]
}

output "list_list_condition" {
  value = [
    for k, v in local.ec2_csv : [v.Region] if v.instance_type == "nano"
  ]
}

output "instance_count_by_type" {
  value = {
    for k, v in local.distinct_type : v => length([for kk, vv in local.ec2_csv : vv if v == vv.instance_type])
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
      ami_id        = v.AMI_ID
      instance_type = v.instance_type
      region        = v.Region
      team_name     = v.Team_Name
    }
  }
}