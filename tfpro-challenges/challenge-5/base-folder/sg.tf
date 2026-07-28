locals {
  sg_rules = csvdecode(file("${path.module}/sg.csv"))

  app_1_ingress = {
    for index, rule in local.sg_rules : index => rule
    if rule.description == "app-1" && rule.direction == "in"
  }

  app_2_egress = {
    for index, rule in local.sg_rules : index => rule
    if rule.description == "app-2" && rule.direction == "out"
  }
}

module "sg" {
  source = "../modules/sg"

  vpc_id = data.aws_vpc.challenge_5.id
  rules = {
    ingress = local.app_1_ingress
    egress  = local.app_2_egress
  }
}
