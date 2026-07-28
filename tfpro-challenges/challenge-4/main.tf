terraform {
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

  endpoints {
    ec2 = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

locals {
  ec2_data = csvdecode(file("${path.module}/ec2.csv"))

  us_east_instances = [
    for instance in local.ec2_data : instance
    if instance.Region == "us-east-1"
  ]
}

resource "aws_instance" "this" {
  count = length(local.us_east_instances)

  ami = local.us_east_instances[count.index].AMI_ID
  instance_type = lookup({
    micro = "t2.micro"
    nano  = "t3.nano"
  }, local.us_east_instances[count.index].instance_type)

  tags = {
    Name = local.us_east_instances[count.index].Team_Name
  }
}

output "running_ec2" {
  value = [
    for index, instance in aws_instance.this : {
      firewall_id = toset(instance.vpc_security_group_ids)
      id          = instance.id
      region      = local.us_east_instances[index].Region
      subnet      = instance.subnet_id
      team        = local.us_east_instances[index].Team_Name
      type        = local.us_east_instances[index].instance_type
    }
  ]
}
