# S3 버킷 정책을 설정하여 CloudFront에서 읽기 권한을 허용
resource "aws_s3_bucket_policy" "allow_cloudfront_oac" {
  bucket = aws_s3_bucket.tikklemoa_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontOACRead",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = [
          "s3:GetObject"
        ],
        Resource = [
          "${aws_s3_bucket.tikklemoa_bucket.arn}",
          "${aws_s3_bucket.tikklemoa_bucket.arn}/*",
        ],
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cdn.id}"
          }
        }
      },
      {
            "Sid": "AllowAWSBackupRoleAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::661393609088:role/aws-backup-role"
            },
            "Action": [
                "s3:GetBucketTagging",
                "s3:GetBucketLocation",
                "s3:GetBucketVersioning",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:GetBucketNotification",
                "s3:PutBucketNotification",
                "s3:ListBucketVersions"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.tikklemoa_bucket.arn}",
                "arn:aws:s3:::${aws_s3_bucket.tikklemoa_bucket.arn}/*"
            ]
        }
    ]
  })

  depends_on = [aws_cloudfront_distribution.cdn]
}