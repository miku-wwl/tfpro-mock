output "baseline_resource_ids" {
  description = "Identifiers that must remain stable during the exercise."
  value = {
    vpc_id = aws_vpc.harbor.id
    subnet_ids = {
      for index, subnet in aws_subnet.zones : local.subnet_specs[index].key => subnet.id
    }
    security_group_ids = {
      for key, group in aws_security_group.tiers : key => group.id
    }
    instance_ids = {
      for key, instance in aws_instance.nodes : key => instance.id
    }
    iam_role_name         = aws_iam_role.runtime.name
    instance_profile_name = aws_iam_instance_profile.runtime.name
    artifact_bucket_name  = aws_s3_bucket.artifacts.bucket
    artifact_object_key   = aws_s3_object.manifest.key
    state_bucket_name     = aws_s3_bucket.state_store.bucket
  }
}
