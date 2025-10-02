# Monitoring Stack with Email Alerts
resource "helm_release" "prometheus_stack" {
  name             = "prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "~> 61.0"
  namespace        = "monitoring"
  create_namespace = true

  values = [
    yamlencode({
      # Grafana
      grafana = {
        service = {
          type = "LoadBalancer"
        }
        adminPassword = "admin123!"
        persistence = {
          enabled          = true
          size             = "10Gi"
          storageClassName = "gp2"
        }
      }

      # Prometheus
      prometheus = {
        service = {
          type = "LoadBalancer"
        }
        prometheusSpec = {
          retention = "15d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "20Gi"
                  }
                }
              }
            }
          }
        }
      }

      # AlertManager
      alertmanager = {
        service = {
          type = "ClusterIP"
        }
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "5Gi"
                  }
                }
              }
            }
          }
        }
      }
    })
  ]

  depends_on = [aws_eks_cluster.production_eks_cluster]
}

