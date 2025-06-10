terraform init -upgrade
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve

terraform output -json > ./../terraform_output.json

# 인프라 종료
# terraform destroy