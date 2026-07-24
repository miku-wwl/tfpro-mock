output "vpc_id" { value = module.network.vpc_id }
output "subnet_ids" { value = module.network.subnet_ids }
output "subnet_ids_by_zone" { value = module.network.subnet_ids_by_zone }
output "security_group_ids" { value = module.security.security_group_ids }
output "observer_account_id" { value = module.security.observer_account_id }
output "instance_profile_name" { value = module.identity.instance_profile_name }
