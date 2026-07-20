module "operations" {
  source = "./modules/operations"

  assets_bucket_name = var.assets_bucket_name
  logs_bucket_name   = var.logs_bucket_name
}
