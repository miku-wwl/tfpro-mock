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

  endpoints {
    ec2 = "http://127.0.0.1:4566"
    iam = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}


locals {
  csv = csvdecode(file("${path.module}/ec2.csv"))

  filter_csv = [for instance in local.csv : instance if instance.Region == "us-east-1"]
}

resource "aws_instance" "ec2" {
  count = length(local.filter_csv)

  instance_type = local.filter_csv[count.index].instance_type == "micro" ? "t2.micro" : "t3.nano"
  ami           = local.filter_csv[count.index].AMI_ID

  tags = {
    "Name" = local.filter_csv[count.index].Team_Name
  }
}

output "running_ec2" {
  value = [
    for index, value in local.filter_csv : {
      firewall_id = aws_instance.ec2[index].vpc_security_group_ids
      id          = aws_instance.ec2[index].id
      region      = "us-east-1"
      subnet      = aws_instance.ec2[index].subnet_id
      "team"      = value.Team_Name
      "type"      = value.instance_type
    }
  ]
}