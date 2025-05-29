variable "aws_region" {
  default = "ap-northeast-2" # 서울 리전
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  default = "ap-northeast-2a"
}

variable "ami_ubuntu" {
  description = "Ubuntu 20.04 LTS"
  default     = "ami-0d5bb3742db8fc264"
}

variable "key_name" {
  description = "123"
}

variable "acm_certificate_arn" {
  description = "ACM 인증서 ARN (us-east-1 리전에 생성된 것)"
  type        = string
}