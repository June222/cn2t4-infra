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

# 정책 생성
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
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
  role       = aws_iam_role.ec2_jenkins_server_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# 인스턴스 역할 프로파일 생성
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_jenkins_server_role.name
}
