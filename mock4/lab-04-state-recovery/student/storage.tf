resource "aws_s3_bucket" "assets" {
  # Wrong on purpose: applying this unchanged would replace the existing bucket.
  bucket = "${var.lab_prefix}-vault-assets-v2"

  tags = {
    Name        = "${var.lab_prefix}-vault-assets-v2"
    Environment = "exam"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.lab_prefix}-vault-logs"

  tags = {
    Name        = "${var.lab_prefix}-vault-logs"
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
