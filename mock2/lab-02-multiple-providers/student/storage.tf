resource "aws_s3_bucket" "artifact_store" {
  bucket = "tfpro-lab02-artifact-store"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_object" "legacy_artifact" {
  bucket = aws_s3_bucket.artifact_store.id
  key    = "artifact.txt"
  source = "${path.module}/artifact.txt"
  etag   = filemd5("${path.module}/artifact.txt")

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_object" "artifact" {
  provider = aws.compute
  bucket   = aws_s3_bucket.artifact_store.id
  key      = "artifact.txt"
  content  = "ORIGINAL_CONTENT"

  lifecycle {
    prevent_destroy = true
  }
}
