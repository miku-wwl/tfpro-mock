resource "aws_s3_bucket" "artifact_store" {
  provider = aws.compute
  bucket   = "tfpro-lab02-artifact-store"

  lifecycle {
    prevent_destroy = true
  }
}

# resource "aws_s3_bucket_object" "legacy_artifact" {
#   provider = aws.compute
#   bucket   = aws_s3_bucket.artifact_store.id
#   key      = "artifact.txt"
#   source   = "${path.module}/artifact.txt"
#   etag     = filemd5("${path.module}/artifact.txt")

#   lifecycle {
#     prevent_destroy = true
#   }
# }

import {
  id = "tfpro-lab02-artifact-store/artifact.txt"
  to = aws_s3_object.artifact
}

resource "aws_s3_object" "artifact" {
  provider = aws.compute
  bucket   = aws_s3_bucket.artifact_store.id
  key      = "artifact.txt"
  source   = "${path.module}/artifact.txt"
  etag     = filemd5("${path.module}/artifact.txt")

  lifecycle {
    prevent_destroy = true
  }
}