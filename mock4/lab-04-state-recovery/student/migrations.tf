moved {
  from = aws_s3_bucket.primary
  to   = aws_s3_bucket.assets
}

moved {
  from = aws_iam_user.alpha
  to   = aws_iam_user.members["alpha"]
}

moved {
  from = aws_iam_user.beta
  to   = aws_iam_user.members["beta"]
}

moved {
  from = aws_iam_user.gamma
  to   = aws_iam_user.members["gamma"]
}

moved {
  from = aws_vpc_security_group_ingress_rule.legacy_ops
  to   = aws_vpc_security_group_ingress_rule.inbound["ops-tcp-8443"]
}
