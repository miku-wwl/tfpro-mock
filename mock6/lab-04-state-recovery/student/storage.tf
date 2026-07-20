resource "aws_s3_bucket" "assets" {
  bucket        = "${var.assets_bucket_name}-archive"
  force_destroy = false

  tags = {
    Name     = var.assets_bucket_name
    Role     = "asset-library"
    Recovery = "preserve"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "logs" {
  bucket        = var.logs_bucket_name
  force_destroy = false

  tags = {
    Name = var.logs_bucket_name
    Role = "operational-logs"
  }

  lifecycle {
    prevent_destroy = true
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

resource "aws_s3_object" "delivery_receipt" {
  bucket       = aws_s3_bucket.assets.id
  key          = "new.txt"
  content      = "Pending"
  content_type = "text/plain"
  etag         = md5("Pending")
}
