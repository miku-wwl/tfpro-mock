module "compute" {
  source = "./modules/compute"
}

module "identity" {
  source = "./modules/identity"
}

module "storage" {
  source = "./modules/storage"
}

data "aws_caller_identity" "current" {
  provider = aws.compute
}
