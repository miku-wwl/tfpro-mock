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
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    s3  = "http://localhost:4566"
    sts = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Environment = var.environement
    }
  }
}
module "random" {
  source = "./modules/random"
}

module "iam" {
  source   = "./modules/iam"
  pet_id   = "prompt-jawfish"
  org_name = var.org-name
}

module "s3" {
  source      = "./modules/s3"
  pet_id      = "prompt-jawfish"
  s3_buckets  = var.s3_buckets
  base_object = var.s3_base_object
}

module "sg" {
  source = "./modules/sg"
  name   = var.sg_name
}

module "ec2" {
  source               = "./modules/ec2"
  iam_instance_profile = "test_profile"
}

moved {
  from = random_pet.this
  to   = module.random.random_pet.this
}

moved {
  from = data.aws_ami.this
  to   = module.ec2.data.aws_ami.this
}

moved {
  from = aws_instance.this
  to   = module.ec2.aws_instance.this
}

moved {
  from = data.aws_iam_policy_document.assume_role
  to   = module.iam.data.aws_iam_policy_document.assume_role
}

moved {
  from = aws_iam_role.test_role
  to   = module.iam.aws_iam_role.test_role
}

moved {
  from = aws_iam_instance_profile.test_profile
  to   = module.iam.aws_iam_instance_profile.test_profile
}

moved {
  from = aws_iam_user.lb
  to   = module.iam.aws_iam_user.lb
}

moved {
  from = aws_iam_user_policy.lb_ro
  to   = module.iam.aws_iam_user_policy.lb_ro
}

moved {
  from = aws_s3_bucket.example
  to   = module.s3.aws_s3_bucket.example
}

moved {
  from = aws_s3_object.object
  to   = module.s3.aws_s3_object.object
}

moved {
  from = aws_security_group.example
  to   = module.sg.aws_security_group.example
}

moved {
  from = aws_vpc_security_group_ingress_rule.example
  to   = module.sg.aws_vpc_security_group_ingress_rule.example
}
