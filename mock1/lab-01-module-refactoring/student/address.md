aws_iam_instance_profile.runtime
  -> module.identity.aws_iam_instance_profile.runtime

aws_iam_role.runtime
  -> module.identity.aws_iam_role.runtime

aws_instance.nodes["gateway"]
  -> module.compute.aws_instance.nodes["gateway"]

aws_instance.nodes["worker"]
  -> module.compute.aws_instance.nodes["worker"]

aws_security_group.tiers["edge"]
  -> module.security.aws_security_group.tiers["edge"]

aws_security_group.tiers["ops"]
  -> module.security.aws_security_group.tiers["ops"]

aws_security_group.tiers["service"]
  -> module.security.aws_security_group.tiers["service"]

aws_subnet.zones[0]
  -> module.network.aws_subnet.zones["north"]

aws_subnet.zones[1]
  -> module.network.aws_subnet.zones["south"]

aws_vpc.harbor
  -> module.network.aws_vpc.harbor