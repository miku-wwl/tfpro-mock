resource "aws_s3_bucket" "vault" {
  provider = aws.identity
  bucket   = "northstar-release-vault-000000000000"

  tags = {
    DataClass = "release-evidence"
  }
}

output "bucket_id" {
  value = aws_s3_bucket.vault.id
}
