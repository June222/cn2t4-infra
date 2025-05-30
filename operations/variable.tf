
variable "domain_name" {
  description = "도메인 이름 (ex: example.com)"
  type        = string
  default     = "tikklemoa_test.com"
}

variable "subdomain_name" {
  description = "서브도메인 이름 (ex: ci.example.com)"
  type        = string
  default     = "www.tikklemoa_test.com"
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  default     = "eks-cluster-test"
}