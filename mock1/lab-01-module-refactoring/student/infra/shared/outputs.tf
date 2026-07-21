output "vpc_id" {
  description = "VPC ID shared with the application root."
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs keyed by logical subnet name."
  value       = module.network.subnet_ids
}

output "security_group_ids" {
  description = "Security group IDs keyed by logical security group name."
  value       = module.security.security_group_ids
}

output "naming" {
  description = "Shared naming values consumed by the application root."
  value = {
    project     = local.naming.project
    environment = local.naming.environment
    owner       = local.naming.owner
    suffix      = random_pet.suffix.id
  }
}

output "shared_contract" {
  description = "Explicit contract for the application root."
  value = {
    vpc_id             = module.network.vpc_id
    subnet_ids         = module.network.subnet_ids
    security_group_ids = module.security.security_group_ids
    project            = local.naming.project
    environment        = local.naming.environment
    owner              = local.naming.owner
    suffix             = random_pet.suffix.id
  }
}
