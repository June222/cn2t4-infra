# KMS Key 생성
resource "aws_kms_key" "backup_key" {
  description             = "KMS key for backup vault"
  deletion_window_in_days = 10
  enable_key_rotation     = false

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-backup-policy",
    Statement = [
      {
        Sid       = "AllowBackupServiceToUseKey",
        Effect    = "Allow",
        Principal = {
          Service = "backup.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid       = "AllowUserCliAccess",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::661393609088:user/user-cli"
        },
        Action = "kms:*",
        Resource = "*"
      }
    ]
  })
}
# 1. Backup Vault 생성
resource "aws_backup_vault" "my_vault" {
  name        = "daily-backup-vault"
  kms_key_arn  = aws_kms_key.backup_key.arn

}

# 2. IAM Role for Backup (AWS Backup 서비스가 EBS/S3에 접근 가능하도록)
resource "aws_iam_role" "aws_backup_role" {
  name = "aws-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "backup.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 기본 정책을 IAM Role에 연결
locals {
  backup_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  ]
}

resource "aws_iam_role_policy_attachment" "backup_policy_attachments" {
  for_each   = toset(local.backup_policies)
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = each.key
}


# 3. Backup Plan 정의 (일일 백업, 7일 보관)
resource "aws_backup_plan" "daily_plan" {
  name = "Daily-Backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.my_vault.name
    schedule          = "cron(0 8 * * ? *)"  # 매일 KST 17:00 → UTC 08:00
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = 7  # 1주일 후 삭제
    }

    recovery_point_tags = {
      "env" = "prod"
    }
  }
}

# 4. 리소스 선택 (태그 기반: Backup = daily)
resource "aws_backup_selection" "daily_selection" {
  name          = "EC2-S3-Daily-Backup-Selection"
  iam_role_arn  = aws_iam_role.aws_backup_role.arn
  plan_id       = aws_backup_plan.daily_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "daily"
  }
}
