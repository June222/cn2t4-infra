provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "my-test-static-site-bucket-2025-unique"  # 추후 이름만 수정해서 적용 
  force_destroy = true

  tags = {
    Environment = "Teraform"
    Project     = "cn2t4-gitops"
  }
}

resource "aws_s3_bucket_public_access_block" "allow_public_access" {
  bucket = aws_s3_bucket.test_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket     = aws_s3_bucket.test_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.allow_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontRead"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = [
          "${aws_s3_bucket.test_bucket.arn}/*",
          "${aws_s3_bucket.test_bucket.arn}"
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::661393609088:distribution/E8UPBRU7LYVLI"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "reblock_public_policy" {
  bucket = aws_s3_bucket.test_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true     
  restrict_public_buckets = true    
} 