# Elastic IP
resource "aws_eip" "ci_server_eip" {
  instance = aws_instance.ci_server.id

  tags = {
    Name = "ci-server-eip"
  }
}

# CI(Jenkins)용 EC2
resource "aws_instance" "ci_server" {
  ami                    = var.ami_ubuntu
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ci_sg.id]
  # associate_public_ip_address = false
  key_name             = aws_key_pair.ci_ssh_key_pair.key_name
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "ci-server-ec2"
  }
}