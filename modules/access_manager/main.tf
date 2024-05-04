data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ec2_rds_access_role" {
  name = "EC2RDSAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_rds_kms_policy" {
  name   = "EC2RDSKMSAccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = var.rds_kms_key_id
      },
      {
        Effect   = "Allow",
        Action   = [
          "rds:Describe*",
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = var.rds_secret_manager_arn
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "ec2_rds_kms_policy_attachment" {
  name       = "EC2RDSKMSAccessPolicyAttachment"
  roles      = [aws_iam_role.ec2_rds_access_role.name]
  policy_arn = aws_iam_policy.ec2_rds_kms_policy.arn
}
resource "aws_iam_role_policy_attachment" "ec2-ssm-policy" {
role       = aws_iam_role.ec2_rds_access_role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_iam_profile" {
  name = "app_profile"
  role = aws_iam_role.ec2_rds_access_role.name
}

resource "aws_kms_key_policy" "rds_kms_key_policy" {
  key_id = var.rds_kms_key_id
  policy = jsonencode({
    Id = "ec2_rds"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_rds_access_role.arn
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      }
    ]
    Version = "2012-10-17"
  })
}
