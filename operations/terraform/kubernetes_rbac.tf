resource "kubernetes_cluster_role" "helm_secret_reader" {
  metadata {
    name = "helm-secret-reader"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    # https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/access-policy-permissions.html
    verbs = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }
  # depends_on 추가
  depends_on = [aws_eks_access_policy_association.eks_access_policy_associations]
}

resource "kubernetes_cluster_role_binding" "bind_user_cli_to_helm_secret_reader" {
  metadata {
    name = "helm-secret-reader-binding"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.helm_secret_reader.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "Group"      # "User"가 아닌 "Group"
    name      = "eks-admins" # 이 라인과 main.tf line 69가 같아야함.
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [kubernetes_cluster_role.helm_secret_reader]
}
