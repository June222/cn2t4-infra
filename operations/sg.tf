resource "aws_security_group" "istio_lb_sg" {
  name   = "istio-lb-sg"
  vpc_id = module.vpc.vpc_id
}

# LoadBalancer에 적용될 보안 그룹 규칙 추가 (포트 80)
resource "aws_security_group_rule" "sg_allow_http_from_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.istio_lb_sg.id
  description       = "sg for EKS Cluster Allowing HTTP from anywhere"
  depends_on        = [module.eks]
}

# LoadBalancer에 적용될 보안 그룹 규칙 추가 (포트 443)
resource "aws_security_group_rule" "sg_allow_https_from_anywhere" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.istio_lb_sg.id
  description       = "sg for EKS Cluster Allowing HTTPS from anywhere"
  depends_on        = [module.eks]
}
