# terraform init
terraform fmt
terraform validate
terraform apply -auto-approve -refresh=false

# 인프라 종료
# terraform destroy -input=false -auto-approve
