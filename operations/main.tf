provider "aws" {
  region = "us-east-1" # Route 53은 글로벌 리전
}

# # 1. Hosted Zone 생성
# resource "aws_route53_zone" "main" {
#   name = var.domain_name
# }

# # 2. A 레코드 등록 (예: EC2 IP 연결)
# resource "aws_route53_record" "a_record" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.subdomain_name
#   type    = "A"
#   ttl     = 300
#   records = ["167.189.190.1"] # 예: EC2 또는 EIP
# }

# 또는 ALIAS 레코드 (CloudFront 등 사용 시)
# resource "aws_route53_record" "alias" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.subdomain
#   type    = "A"
#   alias {
#     name                   = aws_cloudfront_distribution.cdn.domain_name
#     zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
#     evaluate_target_health = false
#   }
# }


# VPC 생성
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
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
  cluster_version = "1.28"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      instance_type = ["t3.medium"]
      desired_size  = 2
      min_size      = 1
      max_size      = 3
    }
    tags = {
      Environment = "prod"
      Project     = "web-1"
    }
  }
}
