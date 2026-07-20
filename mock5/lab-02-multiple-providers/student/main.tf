module "compute" {
  source = "./modules/compute"
}

module "identity" {
  source = "./modules/identity"
}

module "storage" {
  source = "./modules/storage"
}

data "aws_caller_identity" "current" {}

# The target type exists, but applying before safe state migration is destructive.
resource "aws_s3_object" "artifact" {
  bucket       = module.storage.bucket_name
  key          = "artifact.txt"
  source       = "${path.module}/artifact.txt"
  etag         = filemd5("${path.module}/artifact.txt")
  content_type = "text/plain; charset=utf-8"
}
