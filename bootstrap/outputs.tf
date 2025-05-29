output "vpc_id" {
  value = aws_vpc.ci_vpc.id
}

output "subnet_id" {
  value = aws_subnet.ci_subnet.id
}

output "jenkins_ip" {
  description = "Public IP of Jenkins EC2"
  value       = aws_eip.ci_server_eip.public_ip
}

output "bucket_name" {
  value = aws_s3_bucket.tikklemoa_bucket.id
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.cloudfront_cert.arn
}

output "certificate_domain" {
  description = "The domain for the certificate"
  value       = aws_acm_certificate.cloudfront_cert.domain_name
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.alb_cert.arn
}

output "certificate_domain" {
  description = "The domain for the certificate"
  value       = aws_acm_certificate.alb_cert.domain_name
}