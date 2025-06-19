resource "aws_iam_role_policy" "aws_backup_custom_policy" {
  name = "aws-backup-custom-policy"
  role = aws_iam_role.aws_backup_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowBackupServiceToUseKey",
        Effect: "Allow",
        Action: "backup:*",
        Resource: [
          "arn:aws:backup:ap-northeast-2:661393609088:backup-vault:daily-backup-vault",
          "arn:aws:backup:ap-northeast-2:661393609088:backup-plan:*",
          "*"
        ]
      },
      {
        Sid: "AllowBackupServiceToUseKMSKey",
        Effect: "Allow",
        Action: [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:PutKeyPolicy",
          "kms:GetKeyPolicy",
          "kms:CreateKey"
        ],
        Resource: "*"
      },
      {
        Sid: "AllowUserCliAccess",
        Effect: "Allow",
        Action: [
          "s3:GetBucketTagging",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetBucketNotification",
          "s3:PutBucketNotification",
          "s3:ListBucketVersions",
          "s3:GetObjectTagging",
          "s3:GetObjectVersion"
        ],
        Resource: [
          "arn:aws:s3:::${aws_s3_bucket.tikklemoa_bucket.arn}",
          "arn:aws:s3:::${aws_s3_bucket.tikklemoa_bucket.arn}/*"
        ]
      },
      {
        Sid: "AllowBackupEventBridge",
        Effect: "Allow",
        Action: [
          "events:ListRules",
          "events:ListTargetsByRule",
          "events:DescribeRule",
          "events:PutRule",
          "events:PutTargets"
        ],
        Resource: "*"
      },
      {
        Sid: "AllowCloudWatchMetrics",
        Effect: "Allow",
        Action: [
          "cloudwatch:GetMetricData"
        ],
        Resource: "*"
      }
    ]
  })
}