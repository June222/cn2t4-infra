# VPC 생성
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  # terraform destroy 시에 nat_gateway가 삭제되지 않는 문제가 발생했는데
  # 해당 코드 삭제하니 자동 삭제가 됨.
  # single_nat_gateway = true

  tags = {
    Name = "backend-vpc",
    Type = "EKS"
  }
}