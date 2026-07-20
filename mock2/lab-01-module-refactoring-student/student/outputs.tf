output "vpc_id" {
  description = "Identifier of the existing VPC."
  value       = aws_vpc.fabric.id
}

output "subnet_ids" {
  description = "Legacy ordered subnet output. The target contract must use stable keys."
  value       = aws_subnet.zone[*].id
}

output "security_group_ids" {
  description = "Security group IDs keyed by tier name."
  value       = { for key, group in aws_security_group.tier : key => group.id }
}

output "instance_ids" {
  description = "EC2 IDs keyed by node name."
  value       = { for key, instance in aws_instance.node : key => instance.id }
}

output "state_bucket_name" {
  description = "Bucket that will host the two final state objects."
  value       = aws_s3_bucket.state_store.id
}

output "artifact_bucket_name" {
  description = "Artifact bucket name."
  value       = aws_s3_bucket.artifact_store.id
}

output "artifact_object_key" {
  description = "Retained object key."
  value       = aws_s3_object.seed_manifest.key
}

output "baseline_resource_ids" {
  description = "Machine-readable identifiers captured by setup scripts after a real apply."
  value = {
    vpc_id = aws_vpc.fabric.id
    subnet_ids = {
      for index, subnet in aws_subnet.zone : var.segment_blueprints[index].key => subnet.id
    }
    security_group_ids = {
      for key, group in aws_security_group.tier : key => group.id
    }
    instance_ids = {
      for key, instance in aws_instance.node : key => instance.id
    }
    iam_role_name        = aws_iam_role.workload.name
    instance_profile_name = aws_iam_instance_profile.workload.name
    artifact_bucket_name = aws_s3_bucket.artifact_store.id
    artifact_object_key  = aws_s3_object.seed_manifest.key
    state_bucket_name    = aws_s3_bucket.state_store.id
  }
}
