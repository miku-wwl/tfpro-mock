resource "aws_s3_object" "artifact" {
  provider = aws.compute
  bucket   = module.storage.bucket_name
  key      = "artifact.txt"
  content  = file("${path.module}/artifact.txt")

  lifecycle {
    ignore_changes = [content, force_destroy]
  }
}
