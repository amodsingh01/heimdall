resource "aws_iam_role" "Heimdall-EC2-role" {
  name = "Heimdall-EC2-${random_pet.server.id}-${random_id.server.dec}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]
}
resource "aws_iam_instance_profile" "Heimdall-EC2-role" {
  name = "Heimdall-EC2-role-${random_pet.server.id}-${random_id.server.dec}"
  role = aws_iam_role.Heimdall-EC2-role.name
}