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
  from = aws_s3_bucket.primary
  to   = aws_s3_bucket.assets
}

moved {
  from = aws_security_group_rule.legacy_api
  to   = aws_security_group_rule.inbound["api"]
}

import {
  id = "tfpro-lab04-logs"
  to = aws_s3_bucket.logs
}

import {
  id = "sg-880234f98df1685f8"
  to = aws_security_group.application
}


import {
  id = "sg-880234f98df1685f8_ingress_tcp_8443_8443_10.42.0.0/16"
  to = aws_security_group_rule.inbound["ops"]
}

