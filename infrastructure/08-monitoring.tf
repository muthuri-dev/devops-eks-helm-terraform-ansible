# Monitoring Stack - Prometheus & Grafana
# Simple deployment using Helm charts

# Prometheus Stack (includes Prometheus, Grafana, AlertManager, Node Exporter)
resource "helm_release" "prometheus_stack" {
  name             = "prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "~> 61.0"
  namespace        = "monitoring"
  create_namespace = true

  # Basic values for the prometheus stack
  values = [
    yamlencode({
      # Grafana configuration - expose via LoadBalancer
      grafana = {
        service = {
          type = "LoadBalancer"
        }
        adminPassword = "admin123!"
      }

      # Prometheus configuration - expose via LoadBalancer
      prometheus = {
        service = {
          type = "LoadBalancer"
        }
      }

      # Keep AlertManager internal
      alertmanager = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [aws_eks_cluster.production_eks_cluster]
}

