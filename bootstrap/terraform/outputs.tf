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

output "ec2_sg_id" {
  description = "Security Group id of EC2 Instance"
  value       = aws_security_group.ci_sg.id
}

output "private_key_pem" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}