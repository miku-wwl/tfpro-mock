output "shared_name" { value = random_pet.release_marker.id }
output "vpc_id" { value = module.network.vpc_id }
output "subnet_ids" { value = module.network.subnet_ids }
output "security_group_ids" { value = module.security.security_group_ids }
output "artifact_bucket_name" { value = aws_s3_bucket.artifact_store.id }
output "state_bucket_name" { value = aws_s3_bucket.state_archive.id }
