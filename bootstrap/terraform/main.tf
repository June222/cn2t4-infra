provider "aws" {
  region = var.aws_region
}

# 1. vpc
resource "aws_vpc" "ci_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "ci-vpc"
  }
}

# 2. 인터넷 게이트웨이
resource "aws_internet_gateway" "ci_igw" {
  vpc_id = aws_vpc.ci_vpc.id

  tags = {
    Name = "ci-igw"
  }
}

# 3. 서브넷
resource "aws_subnet" "ci_subnet" {
  vpc_id                  = aws_vpc.ci_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "ci-subnet"
  }
}

# 4. 라우팅 테이블
resource "aws_route_table" "ci_rt" {
  vpc_id = aws_vpc.ci_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ci_igw.id
  }

  tags = {
    Name = "ci-rt"
  }
}

# 5. 라우팅 테이블과 서브넷 연결
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.ci_subnet.id
  route_table_id = aws_route_table.ci_rt.id
}

resource "aws_security_group" "ci_sg" {
  name        = "ci-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.ci_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins Port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ci-sg"
  }
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
  subnet_id                   = aws_subnet.ci_subnet.id
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