#!/bin/bash

terraform init -upgrade
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve

# eip 출력
terraform output -json jenkins_ip > ./../terraform_output.json

# Terraform output을 PEM 파일로 저장
terraform output -raw private_key_pem > ./ci-ssh-key.pem
chmod 400 ./../ci-ssh-key.pem


# 인프라 종료
# terraform destroy