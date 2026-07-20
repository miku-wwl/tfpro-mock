output "instance_ids" {
  value = { for key, instance in aws_instance.node : key => instance.id }
}
