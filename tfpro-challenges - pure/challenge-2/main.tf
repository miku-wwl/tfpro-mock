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
    iam = "http://127.0.0.1:4566"
    s3  = "http://127.0.0.1:4566"
    ec2 = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
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

module "ec2" {
  source = "./modules/ec2"

  name = module.iam.name
}

module "iam" {
  source = "./modules/iam"

  id       = module.random.id
  org-name = var.org-name
}

module "s3" {
  source = "./modules/s3"

  s3_buckets     = var.s3_buckets
  id             = module.random.id
  s3_base_object = var.s3_base_object
}

module "sg" {
  source = "./modules/sg"

  sg_name = var.sg_name
}


moved {
  from = data.aws_iam_policy_document.assume_role
  to = module.iam.data.aws_iam_policy_document.assume_role
}

moved {
  from = aws_iam_instance_profile.test_profile
  to = module.iam.aws_iam_instance_profile.test_profile
}

moved {
  from = aws_iam_role.test_role
  to = module.iam.aws_iam_role.test_role
}
moved {
  from = aws_iam_user.lb[0]
  to = module.iam.aws_iam_user.lb[0]
}

moved {
  from = aws_iam_user.lb[1]
  to = module.iam.aws_iam_user.lb[1]
}

moved {
  from = aws_iam_user.lb[2]
  to = module.iam.aws_iam_user.lb[2]
}

moved {
  from = aws_iam_user_policy.lb_ro[0]
  to = module.iam.aws_iam_user_policy.lb_ro[0]
}

moved {
  from = aws_iam_user_policy.lb_ro[1]
  to = module.iam.aws_iam_user_policy.lb_ro[1]
}

moved {
  from = aws_iam_user_policy.lb_ro[2]
  to = module.iam.aws_iam_user_policy.lb_ro[2]
}

moved {
  from = aws_instance.this
  to = module.ec2.aws_instance.this
}

moved {
  from = aws_s3_bucket.example["kplabs-1"]
  to = module.s3.aws_s3_bucket.example["kplabs-1"]
}

moved {
  from = aws_s3_object.object["kplabs-1"]
  to = module.s3.aws_s3_object.object["kplabs-1"]
}

moved {
  from = aws_s3_object.object["kplabs-2"]
  to = module.s3.aws_s3_object.object["kplabs-2"]
}

moved {
  from = random_pet.this
  to = module.random.random_pet.this
}