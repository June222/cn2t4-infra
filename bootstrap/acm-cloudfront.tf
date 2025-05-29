provider "aws" {
  alias  = "virginia"
  region = "us-east-1" # CloudFront용 인증서는 반드시 us-east-1에 있어야 함
}

resource "aws_acm_certificate" "cloudfront_cert" {
  provider = aws.virginia
  domain_name               = "tikklemoa.com"
  validation_method         = "DNS"
  subject_alternative_names = ["www.tikklemoa.com"]
  key_algorithm             = "RSA_2048"
    tags = {
    Environment = "cloudfront"
    }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = "Z077841636QBQU32SBCB3" # 실제 Route53 Hosted Zone ID로 교체
  name    = each.value.name
  type    = each.value.type
  ttl     = 1800
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "cert_acm_validation" {
  certificate_arn         = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}