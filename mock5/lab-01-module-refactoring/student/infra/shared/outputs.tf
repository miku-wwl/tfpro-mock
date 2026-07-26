output "network_id" { value = module.network.vpc_id }
output "subnet_ids_by_zone" { value = module.network.subnet_ids }
output "security_group_ids_by_tier" { value = module.security.security_group_ids }
output "shared_name_token" { value = random_pet.naming.id }
output "artifact_bucket_name" { value = aws_s3_bucket.artifacts.bucket }
output "retained_object_key" { value = aws_s3_object.manifest.key }
