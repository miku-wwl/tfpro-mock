# The existing state currently points to this legacy address.
resource "aws_s3_bucket_object" "legacy_artifact" {
  bucket  = module.storage.bucket_name
  key     = "artifact.txt"
  content = "ORIGINAL-CONTENT"
}

# A direct apply would make two resource addresses compete for one remote object.
resource "aws_s3_object" "artifact" {
  bucket  = module.storage.bucket_name
  key     = "artifact.txt"
  content = file("${path.module}/artifact.txt")
}
