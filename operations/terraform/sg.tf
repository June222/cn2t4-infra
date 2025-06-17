resource "aws_security_group_rule" "allow_ec2_to_eks" {
  type                     = "ingress"
  from_port                = 443 # 접근 방식은 kubectl CLI를 통한 API 호출 (443 포트)
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id # EKS 쪽 보안그룹
  source_security_group_id = local.bootstrap_config.ec2_sg_id     # EC2 보안그룹
  description              = "Allow EC2 to connect to EKS nodes"
  depends_on               = [module.eks]
}