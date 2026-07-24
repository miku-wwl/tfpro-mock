module "compute" {
  source                = "../../modules/compute"
  providers             = { aws.workload = aws.workload }
  account_id            = var.account_id
  ami                   = var.ami
  instance_profile_name = var.instance_profile_name
  name_prefix           = "lab01-${var.environment}"
  subnet_ids            = var.subnet_ids
  security_group_ids    = var.security_group_ids
  workloads             = var.workloads
  common_tags           = var.common_tags
}
