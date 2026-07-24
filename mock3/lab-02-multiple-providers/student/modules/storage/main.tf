data "aws_s3_bucket" "artifacts" {
  provider = aws.compute

  bucket = var.bucket_name
}
