#!/bin/bash

terraform init -upgrade
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve

# eip 출력
terraform output -json > ./../bootstrap_terraform_output.json

jq '{
  vpc_id: .vpc_id.value,
  private_subnet_ids: .private_subnets.value,
  ec2_sg_id: .ec2_sg_id.value
}' ./../bootstrap_terraform_output.json > ./../../operations/bootstrap_config.json


# pem key 위치
KEY_PATH="../ci-ssh-key.pem"

# 파일이 존재하면 삭제 (권한 먼저 변경)
[ -f "$KEY_PATH" ] && chmod +w "$KEY_PATH" && rm -f "$KEY_PATH"

# 새 키 저장
terraform output -raw private_key_pem > "$KEY_PATH"
chmod 400 "$KEY_PATH"


# 인프라 종료
# terraform destroy