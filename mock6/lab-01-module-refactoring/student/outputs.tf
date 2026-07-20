output "shared_name" {
  description = "Generated name segment shared by both future roots."
  value       = random_pet.release_marker.id
}

output "vpc_id" {
  value = aws_vpc.relay_fabric.id
}

output "subnet_ids" {
  value = aws_subnet.relay_segment[*].id
}

output "security_group_ids" {
  value = { for name, group in aws_security_group.boundary : name => group.id }
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.runtime_profile.name
}

output "instance_ids" {
  value = { for name, node in aws_instance.relay_node : name => node.id }
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
    vpc_id                = aws_vpc.relay_fabric.id
    subnet_ids            = aws_subnet.relay_segment[*].id
    security_group_ids    = { for name, group in aws_security_group.boundary : name => group.id }
    instance_ids          = { for name, node in aws_instance.relay_node : name => node.id }
    iam_role_name         = aws_iam_role.runtime_role.name
    instance_profile_name = aws_iam_instance_profile.runtime_profile.name
    artifact_bucket_name  = aws_s3_bucket.artifact_store.id
    artifact_object_key   = aws_s3_object.relay_manifest.key
    state_bucket_name     = aws_s3_bucket.state_archive.id
  }
}
