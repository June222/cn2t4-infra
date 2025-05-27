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
  value = aws_s3_bucket.test_bucket.id
}