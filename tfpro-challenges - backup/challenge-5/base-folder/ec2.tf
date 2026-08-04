# resource "aws_instance" "ec2" {
#   for_each = toset(data.aws_subnets.example.ids)
# 
#   subnet_id     = each.value
#   ami           = "ami-024f768332f0"
#   instance_type = "t2.micro"
# }