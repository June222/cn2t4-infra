output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_id" {
  value = module.vpc.public_subnets[0]
}

output "jenkins_ip" {
  description = "Public IP of Jenkins EC2"
  value       = aws_eip.ci_server_eip.public_ip
}

output "private_key_pem" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}