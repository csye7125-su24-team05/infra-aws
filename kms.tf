resource "aws_kms_key" "ebs_kms_key" {
  provider                = aws.profile
  description             = "KMS key for encrypting EBS volumes"
  deletion_window_in_days = var.kms.deletion_window_in_days
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::905418203195:root"
        },
        Action   = "kms:*",
        Resource = "*",
      },
      {
        Sid    = "Allow administration of the key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::905418203195:user/dev-jay"
        },
        Action = [
          "kms:Update*",
          "kms:UntagResource",
          "kms:TagResource",
          "kms:ScheduleKeyDeletion",
          "kms:Revoke*",
          "kms:ReplicateKey",
          "kms:Put*",
          "kms:List*",
          "kms:ImportKeyMaterial",
          "kms:Get*",
          "kms:Enable*",
          "kms:Disable*",
          "kms:Describe*",
          "kms:Delete*",
          "kms:Create*",
          "kms:CancelKeyDeletion",
        ],
        Resource = "*",
      },
      {
        Sid    = "Allow usage of the key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::905418203195:role/eks-node-role"
        },
        Action = [
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:Decrypt",
        ],
        Resource = "*",
      }
    ]
  })
  tags = merge(var.tags, var.kms.tags)
}
