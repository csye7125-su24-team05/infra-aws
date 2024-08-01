data "aws_iam_policy_document" "eks_assume_role_policy" {
  provider = aws.profile
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_role" {
  provider           = aws.profile
  name               = "eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  provider = aws.profile
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  provider           = aws.profile
  name               = "eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    aws_iam_policy.kms_policy.arn,
    aws_iam_policy.autoscaler_policy.arn,
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

resource "aws_iam_policy" "kms_policy" {
  provider    = aws.profile
  name        = "kms_policy"
  description = "Allow KMS operations"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey",
            "kms:ListKeys",
            "kms:ListGrants",
            "kms:CreateGrant",
            "kms:RevokeGrant",
          ],
          Effect = "Allow",
          Resource = [
            "arn:aws:kms:*:905418203195:key/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_policy" "autoscaler_policy" {
  provider    = aws.profile
  name        = "autoscaler_policy"
  description = "Allow autoscaler operations"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "autoscaling:DescribeTags",
            "ec2:DescribeLaunchTemplateVersions",
            "eks:DescribeNodegroup"
          ],
          Effect = "Allow",
          Resource = [
            "*"
          ]
        }
      ]
    }
  )
}
