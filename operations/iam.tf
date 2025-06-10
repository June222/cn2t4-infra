# 기존에 생성된 유저 불러오기 (data)
data "aws_iam_user" "user_cli" {
  user_name = "user-cli"
}

# 붙일 정책 리스트 (관리형 정책 ARN)
locals {
  eks_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]
}

# for_each로 여러 정책을 한 번에 attach
resource "aws_iam_user_policy_attachment" "eks_user_cli_policies" {
  for_each   = toset(local.eks_policy_arns)
  user       = data.aws_iam_user.user_cli.user_name
  policy_arn = each.value
}

resource "aws_iam_policy" "eks_addon_management_policy-v2" {
  name        = "EKSAddonManagementPolicy"
  description = "Allows managing EKS add-ons"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # add-ons
      {
        Effect = "Allow",
        Action = [
          "eks:*Addon",
          "iam:PassRole"
        ],
        Resource = "*"
      },
      # EKS-AsociateAccessPolicy
      {
        Effect = "Allow",
        Action = [
          "eks:ListAssociatedAccessPolicies",
          "eks:AssociateAccessPolicy",
          "eks:ListAccessEntries",
          "eks:CreateAccessEntry"
        ],
        Resource = [
          "arn:aws:eks:*:661393609088:access-entry/*/*/*/*/*",
          "arn:aws:eks:*:661393609088:cluster/*"
        ]
      }
    ]
  })
}

# cluster 사용자에 attach 
resource "aws_iam_user_policy_attachment" "attach_eks_addon_policy_to_user" {
  user       = aws_iam_user.user_for_k8s_test.name
  policy_arn = aws_iam_policy.eks_addon_management_policy-v2.arn
}

# 유저 생성하기
resource "aws_iam_user" "user_for_k8s_test" {
  name = "user-for-k8s-test"
}

# EKS 정책 List
locals {
  eks_policies = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    # "arn:aws:iam::aws:policy/AWSElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

resource "aws_iam_user_policy_attachment" "attach_eks_policies_to_k8s_user" {
  for_each   = toset(local.eks_policies)
  user       = aws_iam_user.user_for_k8s_test.name
  policy_arn = each.value
}

# node IAM Role
resource "aws_iam_role" "eks_node_role_test" {
  name = "eks-node-role-test"

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

  tags = {
    "type" = "test"
  }
}

# Node Role Policy 
locals {
  eks_node_role_policy = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    # "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]
}

resource "aws_iam_role_policy_attachment" "attach_eks_policies_to_node_role" {
  for_each   = toset(local.eks_node_role_policy)
  role       = aws_iam_role.eks_node_role_test.name
  policy_arn = each.value
}


# EKS Pod Identity 역할
resource "aws_iam_role" "eks_pod_identity_vpc_cni_role" {
  name = "AmazonEKSPodIdentityAmazonVPCCNIRole-v2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowEksAuthToAssumeRoleForPodIdentity",
        Effect = "Allow",
        Principal = {
          Service = "pods.eks.amazonaws.com"
        },
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name = "AmazonEKSPodIdentityAmazonVPCCNIRole-v2"
  }
}
# 위 역할에 EKS_CNI_Policy 붙이기
resource "aws_iam_role_policy_attachment" "attach_cni_policy_to_vpc_cni_role" {
  role       = aws_iam_role.eks_pod_identity_vpc_cni_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}