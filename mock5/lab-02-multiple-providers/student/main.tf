module "compute" {
  source = "./modules/compute"

  providers = {
    aws.compute = aws.compute
  }
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
}

data "aws_caller_identity" "current" {
  provider = aws.readonly
}

# The target type exists, but applying before safe state migration is destructive.
resource "aws_s3_object" "artifact" {
  provider = aws.compute
  bucket   = module.storage.bucket_name
  key      = "artifact.txt"
  source   = "${path.module}/artifact.txt"
  etag     = filemd5("${path.module}/artifact.txt")
}
