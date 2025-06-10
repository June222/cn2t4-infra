output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_id" {
  value = module.vpc.public_subnets[0].id
}

output "jenkins_ip" {
  description = "Public IP of Jenkins EC2"
  value       = aws_eip.ci_server_eip.public_ip
}