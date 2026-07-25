resource "aws_s3_bucket" "artifact" {
  provider = aws.compute
  bucket   = "lab02-nimbus-artifacts"
}
