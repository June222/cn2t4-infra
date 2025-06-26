resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "tikklemoa-oac"
  description                       = "OAC for accessing S3 securely"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  provider = aws.virginia
  origin {
    domain_name = aws_s3_bucket.tikklemoa_bucket.bucket_regional_domain_name
    origin_id   = "s3-Origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "s3-Origin"

    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
    response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront_cert.arn # 여기에서 사용자 지정 인증서 ARN 사용
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  price_class = "PriceClass_200"                       # 한국 포함 아시아 커버
  aliases     = ["tikklemoa.com", "www.tikklemoa.com"] # 사용자 도메인에 대응

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [aws_s3_bucket.tikklemoa_bucket]
}