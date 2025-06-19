# S3 버킷을 생성
resource "aws_s3_bucket" "tikklemoa_bucket" {
  bucket        = "tikklemoa-bucket-test" # 추후 이름만 수정해서 적용 
  force_destroy = true

  tags = {
    Environment = "dev"
    Project     = "cn2t4-gitops"
    Name        = "VersionedBucket"
    Backup = "daily"
  }
}

# S3 버킷에 대한 버전 관리 설정
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tikklemoa_bucket.id

  versioning_configuration {
    status = "Enabled" # 또는 "Suspended"
  }
}

# S3 버킷에 대한 퍼블릭 액세스 차단 설정
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.tikklemoa_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}