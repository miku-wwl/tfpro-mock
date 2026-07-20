output "instance_ids" {
  value = {
    for key, instance in aws_instance.nodes : key => instance.id
  }
}
