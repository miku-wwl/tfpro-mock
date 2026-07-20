resource "aws_s3_bucket" "artifact_store" {
  bucket        = "tfpro-lab02-artifacts"
  force_destroy = false
}
