output "shared_name" {
  description = "Generated name segment shared by both future roots."
  value       = random_pet.release_marker.id
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "subnet_ids" {
  value = values(module.network.subnet_ids)
}

output "security_group_ids" {
  value = module.security.security_group_ids
}

output "instance_profile_name" {
  value = module.identity.instance_profile_name
}

output "instance_ids" {
  value = module.compute.instance_ids
}

output "artifact_bucket_name" {
  value = aws_s3_bucket.artifact_store.id
}

output "artifact_object_key" {
  value = aws_s3_object.relay_manifest.key
}

output "state_bucket_name" {
  value = aws_s3_bucket.state_archive.id
}

output "baseline_resource_ids" {
  value = {
    vpc_id                = module.network.vpc_id
    subnet_ids            = values(module.network.subnet_ids)
    security_group_ids    = module.security.security_group_ids
    instance_ids          = module.compute.instance_ids
    iam_role_name         = module.identity.role_name
    instance_profile_name = module.identity.instance_profile_name
    artifact_bucket_name  = aws_s3_bucket.artifact_store.id
    artifact_object_key   = aws_s3_object.relay_manifest.key
    state_bucket_name     = aws_s3_bucket.state_archive.id
  }
}
