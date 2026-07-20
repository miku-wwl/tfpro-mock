output "instance_ids" {
  value = { for name, node in aws_instance.relay_node : name => node.id }
}
