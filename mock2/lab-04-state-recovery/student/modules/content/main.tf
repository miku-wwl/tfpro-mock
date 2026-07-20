resource "aws_s3_object" "base" {
  bucket  = var.bucket_name
  key     = "base.txt"
  content = "BASE-CONTENT"
  tags    = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
