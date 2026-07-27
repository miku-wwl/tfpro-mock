resource "random_pet" "release_marker" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "artifact_store" {
  bucket        = "northstar-${random_pet.release_marker.id}-artifacts"
  force_destroy = true

  tags = {
    Name = "northstar-${random_pet.release_marker.id}-artifacts"
  }
}

resource "aws_s3_object" "relay_manifest" {
  bucket       = aws_s3_bucket.artifact_store.id
  key          = "manifests/relay.json"
  content_type = "application/json"
  content = jsonencode({
    service = var.business_metadata.service
    stage   = var.business_metadata.stage
    release = random_pet.release_marker.id
  })
}

resource "aws_s3_bucket" "state_archive" {
  bucket        = "northstar-${random_pet.release_marker.id}-tfstate"
  force_destroy = true

  tags = {
    Name    = "northstar-${random_pet.release_marker.id}-tfstate"
    Purpose = "Terraform state"
  }
}
