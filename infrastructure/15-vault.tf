
# Vault using Helm
resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.31.0"
  namespace  = "vault"
  create_namespace = true

  set {
    name  = "server.ha.enabled"
    value = "false"
  }

  set {
    name  = "server.dataStorage.enabled"
    value = "true"
  }

  set {
    name  = "server.dataStorage.size"
    value = "5Gi"
  }

  set {
    name  = "server.dataStorage.storageClass"
    value = "gp2"
  }

  set {
    name  = "ui.enabled"
    value = "true"
  }

  # Enable LoadBalancer service for external access
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "ui.serviceType"
    value = "LoadBalancer"
  }

  depends_on = [aws_eks_node_group.eks_node_group]
}