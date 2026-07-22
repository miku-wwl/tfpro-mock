module "catalog" {
  providers = {
    aws.compute = aws.compute
  }
  source = "./modules/catalog"

  bucket_name = var.bucket_name
}
