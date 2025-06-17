data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
# 기존 도메인에 대한 Route53 Hosted Zone 정보 가져오기
data "aws_route53_zone" "selected" {
  name         = "tikklemoa.com." # [중요] 마지막에 "." 추가하기
  private_zone = false
}