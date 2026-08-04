output "id" {
  value = aws_vpc.main.id
}


output "subnet_ids" {
  value = [for s in aws_subnet.challenge_5 : s.id]
}