resource "aws_s3_object" "manifest" {
  provider = aws.compute
  bucket   = var.bucket_name
  key      = "catalog/manifest.json"
  content  = jsonencode({ schema = 1, owner = "platform" })

  lifecycle {
    prevent_destroy = true
  }
}
