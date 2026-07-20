output "vpc_id" {
  value = data.aws_vpc.selected.id
}

output "subnet_ids" {
  value = { for name, subnet in data.aws_subnet.selected : name => subnet.id }
}

output "subnet_cidrs" {
  value = { for name, subnet in data.aws_subnet.selected : name => subnet.cidr_block }
}

output "security_group_ids" {
  value = { for name, sg in data.aws_security_group.selected : name => sg.id }
}

output "caller_account_id" {
  value = data.aws_caller_identity.audit.account_id
}
