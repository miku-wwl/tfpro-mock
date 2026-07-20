resource "aws_s3_object" "artifact" {
  bucket  = module.storage.bucket_id
  key     = "artifact.txt"
  content = file("${path.module}/payload/artifact.txt")
  etag    = filemd5("${path.module}/payload/artifact.txt")
}
