# CloudNativePG - PostgreSQL Operator for Kubernetes

resource "helm_release" "cloudnative_pg" {
  name             = "cnpg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  namespace        = "cnpg-system"
  create_namespace = true

  depends_on = [
    aws_eks_cluster.production_eks_cluster,
    aws_eks_node_group.eks_node_group
  ]
}
