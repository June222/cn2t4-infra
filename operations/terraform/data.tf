data "kubernetes_ingress_v1" "backend_ingress" {
  metadata {
    name      = "app-ingress"
    namespace = "default"
  }
}

data "aws_route53_zone" "selected" {
  name         = "tikklemoa.com." # [중요] 마지막에 "." 추가하기
  private_zone = false
}

data "aws_acm_certificate" "alb_cert" {
  provider    = aws.virginia
  domain      = "api.tikklemoa.com"
  statuses    = ["ISSUED"]
  most_recent = true
}