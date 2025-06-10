# 역할 생성
resource "aws_iam_role" "ec2_jenkins_server_role" {
  name = "ec2-jenkins-server-role"

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

locals {
  jenkins_iam_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::661393609088:policy/EKSAssociateAccessPolicy" # ← 사용자 정의 정책
  ]
}

# # 역할 - 정책 연결
resource "aws_iam_role_policy_attachment" "ec2_s3_attachment" {
  for_each   = toset(local.jenkins_iam_policies)
  role       = aws_iam_role.ec2_jenkins_server_role.name
  policy_arn = each.value
}

# 인스턴스 역할 프로파일 생성
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_jenkins_server_role.name
}
