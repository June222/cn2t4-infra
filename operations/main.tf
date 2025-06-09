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
    Name = "eks-vpc"
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

  eks_managed_node_groups = {
    default = {
      instance_types = ["t2.micro"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3

      # iam_role_arn = aws_iam_role.eks_node_role.arn

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

# ✅ 애드온 정의
resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "eks-pod-identity-agent"
  service_account_role_arn    = aws_iam_role.eks_pod_identity_vpc_cni_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
}