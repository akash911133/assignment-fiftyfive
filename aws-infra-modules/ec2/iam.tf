resource "aws_iam_role" "ec2_app_role" {
  name = "${var.client_name}-ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "app_permissions" {
  name = "${var.client_name}-app-permissions"
  role = aws_iam_role.ec2_app_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.client_name}-instance-profile"
  role = aws_iam_role.ec2_app_role.name
}

# Bastion: read SSH private key from Secrets Manager (for /opt/id_rsa)
resource "aws_iam_role" "bastion_role" {
  name = "${var.client_name}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "bastion_secrets" {
  name   = "${var.client_name}-bastion-secrets"
  role   = aws_iam_role.bastion_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = "arn:aws:secretsmanager:${var.bastion_private_key_secret_region}:${var.aws_account_id}:secret:${var.bastion_private_key_secret_name}*"
    }]
  })
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.client_name}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}
