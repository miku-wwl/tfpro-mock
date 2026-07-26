resource "aws_s3_bucket" "assets" {
  bucket = local.baseline.buckets.assets

  tags = {
    Name        = local.baseline.buckets.assets
    Environment = "exam"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = local.baseline.buckets.logs

  tags = {
    Name        = local.baseline.buckets.logs
    Environment = "exam"
  }
}

resource "aws_s3_object" "base" {
  bucket  = aws_s3_bucket.assets.id
  key     = "base.txt"
  content = "BASE-CONTENT"
}

resource "aws_s3_object" "retained" {
  bucket  = aws_s3_bucket.assets.id
  key     = "retained.txt"
  content = "KEEP-ME"
}

resource "aws_s3_object" "new" {
  bucket  = aws_s3_bucket.assets.id
  key     = "new.txt"
  content = "TODO"
}
