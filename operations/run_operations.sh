terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve

aws eks update-kubeconfig --region ap-northeast-2 --name eks-cluster-test

terraform output -json > output.json
# kubectl get nodes
# 인프라 종료
# terraform destroy -input=false -auto-approve
