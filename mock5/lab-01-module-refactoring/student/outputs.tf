output "baseline_resource_ids" {
  description = "Identifiers recorded by setup for no-replacement review."
  value = {
    vpc_id = aws_vpc.platform.id
    subnet_ids = {
      for index, definition in var.segment_definitions : definition.key => aws_subnet.segment[index].id
    }
    security_group_ids = {
      for key, group in aws_security_group.tier : key => group.id
    }
    instance_ids = {
      for key, instance in aws_instance.node : key => instance.id
    }
    iam_role_name         = aws_iam_role.runtime.name
    instance_profile_name = aws_iam_instance_profile.runtime.name
    artifact_bucket_name  = aws_s3_bucket.artifacts.id
    retained_object_key   = aws_s3_object.manifest.key
    state_bucket_name     = aws_s3_bucket.state_store.id
    shared_name_token     = random_pet.naming.id
  }
}
