data "aws_caller_identity" "current" {}

data "aws_vpc" "lab" {
  filter {
    name   = "tag:Name"
    values = ["tfpro-lab02-vpc"]
  }
}

data "aws_subnets" "lab" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lab.id]
  }
}

data "aws_launch_template" "workload" {
  name = "tfpro-lab02-template"
}

locals {
  artifact_bucket = "tfpro-lab02-artifacts-${data.aws_caller_identity.current.account_id}"
}

module "compute" {
  source = "./modules/compute"

  # The module receives a valid provider, but it is the wrong identity.
  providers = {
    aws = aws.identity
  }

  launch_template_id = data.aws_launch_template.workload.id
  subnet_ids          = sort(data.aws_subnets.lab.ids)
  desired_capacity    = 2
}

module "identity" {
  source = "./modules/identity"
}

module "storage" {
  source = "./modules/storage"

  bucket_name = local.artifact_bucket
}
