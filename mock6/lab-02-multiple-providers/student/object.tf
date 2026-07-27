resource "aws_s3_object" "artifact" {
  provider = aws.identity
  bucket   = module.storage.bucket_id
  key      = "artifact.txt"
}
