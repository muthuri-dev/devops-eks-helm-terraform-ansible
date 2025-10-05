# Simple Monitoring Stack using Helm defaults
resource "helm_release" "prometheus_stack" {
  name             = "prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "gp2"
  }

  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName"
    value = "gp2"
  }

  set {
    name  = "grafana.persistence.storageClassName"
    value = "gp2"
  }

  depends_on = [aws_eks_cluster.production_eks_cluster]
}

# Grafana Ingress with TLS
resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name      = "grafana-ingress"
    namespace = "monitoring"
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"
    
    tls {
      hosts       = ["grafana.shipcodes.tech"]
      secret_name = "grafana-tls"
    }
    
    rule {
      host = "grafana.shipcodes.tech"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-stack-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.prometheus_stack, helm_release.nginx_ingress, helm_release.cert_manager]
}

