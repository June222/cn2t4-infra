# 백업 사용자 IAM 정책을 정의
resource "aws_iam_user_policy" "user_cli_backup_permissions" {
  name = "user-cli-backup-policy"
  user = "user-cli"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "backup:StartBackupJob",
          "backup:GetBackupJob",
          "backup:ListBackupJobs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = "arn:aws:iam::661393609088:role/aws-backup-role"
      }
    ]
  })
}