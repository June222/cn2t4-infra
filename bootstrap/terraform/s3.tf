# S3 버킷을 생성
resource "aws_s3_bucket" "tikklemoa_bucket" {
  bucket        = "tikklemoa-bucket-test" # 추후 이름만 수정해서 적용 
  force_destroy = true

  tags = {
    Environment = "Teraform"
    Project     = "cn2t4-gitops"
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

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.tikklemoa_bucket.id

  index_document {
    suffix = "index.html"
  }

}

# resource "aws_s3_bucket_cors_configuration" "cors" {
#   bucket = aws_s3_bucket.tikklemoa_bucket.id

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "HEAD"]
#     allowed_origins = ["*"] # 또는 "https://tikklemoa.com" 등으로 제한 가능
#     max_age_seconds = 3000
#   }
# }
