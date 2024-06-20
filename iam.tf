data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_role" {
  name                = "eks-role"
  assume_role_policy  = data.aws_iam_policy_document.eks_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name                = "eks-node-role"
  assume_role_policy  = data.aws_iam_policy_document.eks_node_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

resource "aws_iam_policy" "ebs_volume_policy" {
  name        = "ebs_volume_policy"
  description = "Allow EBS volume operations"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "ec2:Describe*",
            "ec2:RunInstances",
            "ec2:TerminateInstances",
            "ec2:CreateTags",
            "ec2:DeleteTags",
            "ec2:StopInstances",
            "ec2:StartInstances",
            "ec2:RebootInstances",
            "ec2:ModifyInstanceAttribute",
            "ec2:AttachVolume",
            "ec2:DetachVolume",
            "ec2:CreateVolume",
            "ec2:DeleteVolume",
            "ec2:ModifyVolumeAttribute",
            "ec2:DescribeVolumeAttribute"
          ],
          Effect = "Allow",
          Resource = [
            "arn:aws:ec2:*:905418203195:volume/*",
            "arn:aws:ec2:*:905418203195:instance/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_node_role_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.ebs_volume_policy.arn
  depends_on = [aws_iam_policy.ebs_volume_policy, aws_iam_role.eks_node_role]
}