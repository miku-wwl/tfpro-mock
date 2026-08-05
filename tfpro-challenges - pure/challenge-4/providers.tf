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
  ec2        = csvdecode(file("${path.module}/ec2.csv"))
  ec2_filter = [for k, v in local.ec2 : v if v.Region == "us-east-1"]
}

resource "aws_instance" "this" {
  count = length(local.ec2_filter)

  instance_type = local.ec2_filter[count.index].instance_type == "micro" ? "t2.micro" : "t3.nano"
  ami           = local.ec2_filter[count.index].AMI_ID

  tags = {
    Name = local.ec2_filter[count.index].Team_Name
  }
}


output "running_ec2" {
  value = [
    for index, v in local.ec2_filter : {
      firewall_id = aws_instance.this[index].vpc_security_group_ids
      id          = aws_instance.this[index].id
      region      = "us-east-1"
      subnet      = aws_instance.this[index].subnet_id
      team        = local.ec2_filter[index].Team_Name
      type        = local.ec2_filter[index].instance_type
    }
  ]
}