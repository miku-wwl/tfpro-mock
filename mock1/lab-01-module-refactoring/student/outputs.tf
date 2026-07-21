output "baseline_resource_ids" {
  description = "Identifiers that must remain stable during the exercise."

  value = {
    vpc_id = module.network.vpc_id

    subnet_ids = module.network.subnet_ids

    security_group_ids = module.security.security_group_ids

    instance_ids = module.compute.instance_ids

    iam_role_name         = module.identity.role_name
    instance_profile_name = module.identity.instance_profile_name

    artifact_bucket_name = aws_s3_bucket.artifacts.bucket
    artifact_object_key  = aws_s3_object.manifest.key
    state_bucket_name    = aws_s3_bucket.state_store.bucket
  }
}