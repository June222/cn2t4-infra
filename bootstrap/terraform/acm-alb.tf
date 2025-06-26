resource "aws_acm_certificate" "alb_cert" {
  domain_name       = "api.tikklemoa.com"
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"
  tags = {
    Environment = "alb"
  }
}

resource "aws_route53_record" "route53_record_alb" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id # 실제 Route53 Hosted Zone ID로 교체
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "acm_certificate_validation_alb" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record_alb : record.fqdn]
}