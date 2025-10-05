
# Simple Vault using Helm defaults
resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true

  set {
    name  = "server.dataStorage.storageClass"
    value = "gp2"
  }

  depends_on = [aws_eks_node_group.eks_node_group]
}

# Vault UI Ingress with TLS
resource "kubernetes_ingress_v1" "vault_ui_ingress" {
  metadata {
    name      = "vault-ui-ingress"
    namespace = "vault"
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"
    
    tls {
      hosts       = ["vault.shipcodes.tech"]
      secret_name = "vault-tls"
    }
    
    rule {
      host = "vault.shipcodes.tech"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "vault"
              port {
                number = 8200
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.vault, helm_release.nginx_ingress, helm_release.cert_manager]
}
