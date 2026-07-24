data "aws_caller_identity" "current" {
  provider = aws.readonly
}

data "aws_vpc" "lab" {
  provider = aws.compute
  filter {
    name   = "tag:Name"
    values = ["tfpro-lab02-vpc"]
  }
}

data "aws_subnets" "lab" {
  provider = aws.compute
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lab.id]
  }
}

data "aws_launch_template" "workload" {
  provider = aws.compute
  name     = "tfpro-lab02-template"
}

locals {
  artifact_bucket = "tfpro-lab02-artifacts-${data.aws_caller_identity.current.account_id}"
}

module "compute" {
  source = "./modules/compute"

  providers = {
    aws.compute = aws.compute
  }

  launch_template_id = data.aws_launch_template.workload.id
  subnet_ids         = sort(data.aws_subnets.lab.ids)
  desired_capacity   = 2
}

module "identity" {
  source = "./modules/identity"

  providers = {
    aws.identity = aws.identity
  }
}

module "storage" {
  source = "./modules/storage"

  providers = {
    aws.compute = aws.compute
  }

  bucket_name = local.artifact_bucket
}
