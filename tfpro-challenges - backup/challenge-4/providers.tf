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
  
}

# 1. Only create EC2 instance if Region is `us-east-1`

# 2. Inside `aws_instance` resource type, `count` and `count.index` should be used for iterating/looping over data. `for_each` or `for expression` should not be used inside `aws_instance` resource type. You are free to use it elsewhere. There should only be single `aws_instance` resource block in solution code.

# 3. Ensure that the `instance_type`, `ami_id`  are dynamically set based on the CSV file's content.

# 4. The following value of `instance_type`from CSV file should be replaced in `aws_instance` resource type based on the below requirement


# instance_type,AMI_ID,Region,Team_Name
# micro,ami-024f768332f0,us-east-1,Security
# nano,ami-0fd05997b4dff7aac,ap-south-1,SRE
# nano,ami-024f768332f0,us-east-1,DevOps
# micro,ami-0995922d49dc9a17d,ap-southeast-1,SRE