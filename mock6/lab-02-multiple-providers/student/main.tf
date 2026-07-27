module "compute" {
  source    = "./modules/compute"
  providers = { aws.compute = aws.compute }
}
module "identity" {
  source    = "./modules/identity"
  providers = { aws.identity = aws.identity }
}
module "storage" {
  source    = "./modules/storage"
  providers = { aws.identity = aws.identity }
}
data "aws_caller_identity" "current" {
  provider = aws.readonly
}
