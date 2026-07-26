resource "aws_s3_bucket" "artifact_store" {
  provider      = aws.compute
  bucket        = "tfpro-lab02-artifacts"
  force_destroy = false
}
