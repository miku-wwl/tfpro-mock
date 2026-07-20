resource "aws_iam_role" "publisher" {
  name               = "northstar-delivery-publisher"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Service = "artifact-delivery"
  }
}

resource "aws_iam_role_policy" "publisher_access" {
  name   = "artifact-read-access"
  role   = aws_iam_role.publisher.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "arn:aws:s3:::northstar-release-vault-000000000000/artifact.txt"
    }]
  })
}
