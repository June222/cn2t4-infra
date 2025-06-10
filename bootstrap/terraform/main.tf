provider "aws" {
  region = var.aws_region
}

# Elastic IP
resource "aws_eip" "ci_server_eip" {
  instance = aws_instance.ci_server.id
  vpc      = true

  tags = {
    Name = "ci-server-eip"
  }
}

# 역할 생성
resource "aws_iam_role" "ec2_s3_role" {
  name = "jenkins-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
        ]
      }
    ]
  })
}

# 정책 생성
resource "aws_iam_policy" "s3_access_policy" {
  name        = "jenkins-s3-access-policy"
  description = "Allow Jenkins to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "arn:aws:s3:::*"
        ]
      }
    ]
  })
}

# # 역할 - 정책 연결
resource "aws_iam_role_policy_attachment" "ec2_s3_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# 인스턴스 역할 프로파일 생성
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

# CI(Jenkins)용 EC2
resource "aws_instance" "ci_server" {
  ami                         = var.ami_ubuntu
  instance_type               = "t2.small"
  subnet_id                   = module.vpc.public_subnets[0]
  security_groups             = [aws_security_group.ci_sg.id]
  associate_public_ip_address = false
  # iam_instance_profile        = aws_iam_instance_profile.jenkins_instance_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "ci-server-ec2"
  }
}