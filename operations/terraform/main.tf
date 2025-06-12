provider "aws" {
  region = "ap-northeast-2" # Route 53은 글로벌 리전
}

data "aws_availability_zones" "available" {}

# VPC 생성
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "eks-vpc",
    Type = "EKS"
  }
}

# EKS 생성
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_public_access = true # ✅ 추가
  enable_irsa                    = true

  cluster_additional_security_group_ids = [aws_security_group.istio_lb_sg.id]

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
  depends_on = [module.vpc]
}

# 계정들에 액세스 엔트리 추가
resource "aws_eks_access_entry" "eks_access_entries" {
  for_each      = var.eks_access_users
  cluster_name  = "eks-cluster-test"
  principal_arn = each.value
  type          = "STANDARD"
  depends_on    = [module.eks]
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
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
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
  depends_on   = [module.eks]
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"
  depends_on   = [module.eks]
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"
  depends_on   = [module.eks]
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "eks-pod-identity-agent"
  service_account_role_arn    = aws_iam_role.eks_pod_identity_vpc_cni_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on                  = [module.eks, aws_iam_role.eks_pod_identity_vpc_cni_role]
  tags = {
    Name = "Access Entry",
    Type = "EKS"
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.eks_pod_identity_ebs_csi_role.arn
}