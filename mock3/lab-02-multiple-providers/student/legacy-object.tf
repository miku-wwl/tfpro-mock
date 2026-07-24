resource "aws_s3_object" "artifact" {
  provider = aws.compute

  bucket       = local.artifact_bucket
  key          = "artifact.txt"
  content      = var.artifact_content
  content_type = "text/plain"
}
