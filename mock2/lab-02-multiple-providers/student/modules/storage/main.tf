module "catalog" {
  source = "./modules/catalog"

  bucket_name = var.bucket_name
}
