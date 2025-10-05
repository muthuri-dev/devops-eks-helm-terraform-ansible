

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    yamlencode({
      server = {
        config = {
          url = "https://argocd.shipcodes.tech"
        }
        ingress = {
          enabled = true
          tls = {
            enabled = true
          }
        }
        extraArgs = ["--insecure"]
      }
    })
  ]
  depends_on = [aws_eks_cluster.production_eks_cluster]
}

resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["argocd.shipcodes.tech"]
      secret_name = "argocd-tls"
    }
    rule {
      host = "argocd.shipcodes.tech"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.argocd, helm_release.nginx_ingress, helm_release.cert_manager]
}
