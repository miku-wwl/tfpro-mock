moved {
  from = aws_launch_template.capacity_template
  to   = module.compute.aws_launch_template.capacity_template
}

moved {
  from = aws_autoscaling_group.capacity_group
  to   = module.compute.aws_autoscaling_group.capacity_group
}

moved {
  from = aws_iam_user.pipeline_identity
  to   = module.identity.aws_iam_user.pipeline_identity
}

moved {
  from = aws_iam_user.service_accounts[0]
  to   = module.identity.aws_iam_user.service_accounts["api-gateway"]
}

moved {
  from = aws_iam_user.service_accounts[1]
  to   = module.identity.aws_iam_user.service_accounts["batch-worker-prod"]
}

moved {
  from = aws_s3_object.catalog_manifest
  to   = module.storage.module.catalog.aws_s3_object.manifest
}