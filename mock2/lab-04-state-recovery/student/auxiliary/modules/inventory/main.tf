resource "aws_s3_object" "manifest" {
  bucket = var.bucket_name
  key    = "state-manifest.json"
  content = jsonencode({
    assets = var.bucket_name
    logs   = var.logs_bucket_name
  })
  tags = {
    Environment = "simulation"
    ManagedBy   = "student"
    Exercise    = "state-recovery"
  }

  lifecycle {
    prevent_destroy = true
  }
}
