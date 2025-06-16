provider "aws" {
  region = "ap-northeast-2" # Route 53은 글로벌 리전
}

data "aws_availability_zones" "available" {}

locals {
  bootstrap_config = jsondecode(file("../bootstrap_config.json"))
}

# EKS 생성
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name                   = var.cluster_name
  cluster_version                = "1.32"
  vpc_id                         = local.bootstrap_config.vpc_id
  subnet_ids                     = local.bootstrap_config.private_subnet_ids
  cluster_endpoint_public_access = true # ✅ 추가

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.large"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3

      iam_role_additional_policies = {
        pullonly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
        readonly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        worker   = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      }

      tags = {
        Environment = "prod"
        Project     = "web-1"
      }
    }
  }
}

# 20.x 버전부터 module eks에서 따로 분리하여 설정
module "eks_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.8.5"

  depends_on = [module.eks]

  manage_aws_auth_configmap = false

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::661393609088:user/user-cli"
      username = "user-cli"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::661393609088:root"
      username = "root"
      groups   = ["system:masters"]
    }
  ]
}

# 계정들에 액세스 엔트리 추가
resource "aws_eks_access_entry" "eks_access_entries" {
  for_each          = var.eks_access_users
  cluster_name      = var.cluster_name
  kubernetes_groups = ["eks-admins"] # 이 라인과 kubernetes_rbac.tf line 27, 28이 같아야함.
  principal_arn     = each.value
  type              = "STANDARD"
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
  depends_on = [module.eks]
}

# 클러스터 액세스 정책 
resource "aws_eks_access_policy_association" "eks_access_policy_associations" {
  for_each      = var.eks_access_users
  cluster_name  = module.eks.cluster_name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
    # namespaces = ["example-namespace"]
  }

  depends_on = [aws_eks_access_entry.eks_access_entries]
}

# ✅ 애드온 정의
resource "aws_eks_addon" "coredns" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE" # 기존 IRSA 방식 설정을 덮을 수 있음.
  resolve_conflicts_on_update = "OVERWRITE"
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
  depends_on = [module.eks]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE" # 기존 IRSA 방식 설정을 덮을 수 있음.
  resolve_conflicts_on_update = "OVERWRITE"
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
  depends_on = [module.eks]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE" # 기존 IRSA 방식 설정을 덮을 수 있음.
  resolve_conflicts_on_update = "OVERWRITE"
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
  depends_on = [module.eks]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE" # 기존 IRSA 방식 설정을 덮을 수 있음.
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
  depends_on = [module.eks]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE" # 기존 IRSA 방식 설정을 덮을 수 있음.
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [module.eks]
}

