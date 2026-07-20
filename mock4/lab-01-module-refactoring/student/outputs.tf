output "baseline_resource_ids" {
  value = {
    vpc_id = aws_vpc.fabric.id
    subnet_ids = {
      for index_value, subnet in aws_subnet.segment :
      var.subnet_specs[index_value].key => subnet.id
    }
    security_group_ids = {
      for key, group in aws_security_group.boundary : key => group.id
    }
    instance_ids = {
      for key, instance in aws_instance.executor : key => instance.id
    }
    iam_role_name         = aws_iam_role.runtime.name
    instance_profile_name = aws_iam_instance_profile.runtime.name
    artifact_bucket_name  = aws_s3_bucket.artifacts.bucket
    artifact_object_key   = aws_s3_object.manifest.key
    state_bucket_name     = aws_s3_bucket.state_store.bucket
  }
}

output "instance_inventory" {
  value = {
    for key, instance in aws_instance.executor : key => {
      id          = instance.id
      subnet_key  = local.enabled_node_map[key].subnet_key
      description = local.enabled_node_map[key].description
      priority    = local.enabled_node_map[key].priority
    }
  }
}

output "normalized_node_map" {
  value = local.normalized_node_map
}

output "unique_teams" {
  value = local.unique_teams
}
