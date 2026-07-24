output "security_group_ids" {
  value = {
    for name, group in aws_security_group.tier : name => group.id
  }
}

output "observer_account_id" {
  value = data.aws_caller_identity.observer.account_id
}
