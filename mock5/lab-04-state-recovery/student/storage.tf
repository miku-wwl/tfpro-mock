resource "aws_s3_bucket" "assets" {
  bucket = var.assets_bucket_name

  tags = {
    Lab  = "lab-04-state-recovery"
    Role = "assets"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket_name

  tags = {
    Lab  = "lab-04-state-recovery"
    Role = "logs"
  }
}

resource "aws_s3_object" "base" {
  bucket       = aws_s3_bucket.assets.id
  key          = "base.txt"
  content      = "BASE-CONTENT"
  content_type = "text/plain"
  etag         = md5("BASE-CONTENT")
}

resource "aws_s3_object" "retained" {
  bucket       = aws_s3_bucket.assets.id
  key          = "retained.txt"
  content      = "KEEP-ME"
  content_type = "text/plain"
  etag         = md5("KEEP-ME")
}

resource "aws_s3_object" "retired_marker" {
  bucket       = var.assets_bucket_name
  key          = "retired.tmp"
  content      = "STALE-STATE-ONLY"
  content_type = "text/plain"
  etag         = md5("STALE-STATE-ONLY")
}
