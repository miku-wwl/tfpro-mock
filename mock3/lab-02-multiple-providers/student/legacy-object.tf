resource "aws_s3_bucket_object" "legacy_artifact" {
  provider = aws.compute

  bucket       = local.artifact_bucket
  key          = "artifact.txt"
  content      = var.artifact_content
  content_type = "text/plain"
}

# Target resource added before the old state mapping was migrated.
# Applying this configuration directly is unsafe.
resource "aws_s3_object" "artifact" {
  provider = aws.compute

  bucket       = local.artifact_bucket
  key          = "artifact.txt"
  content      = "${var.artifact_content}\n"
  content_type = "text/plain"
}
