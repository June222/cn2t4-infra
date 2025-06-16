resource "kubernetes_cluster_role" "helm_secret_reader" {
  metadata {
    name = "helm-secret-reader"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }
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
    kind      = "Group"
    name      = "eks-admins" 
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [kubernetes_cluster_role.helm_secret_reader]
}
