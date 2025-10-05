
#  EFK Stack using Official Helm Charts
resource "helm_release" "elasticsearch" {
  name             = "elasticsearch"
  repository       = "https://helm.elastic.co"
  chart            = "elasticsearch"
  version          = "8.5.1"
  namespace        = "elastic-stack"
  create_namespace = true

  set {
    name  = "replicas"
    value = "1"
  }
  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name  = "volumeClaimTemplate.storageClassName"
    value = "gp2"
  }

  depends_on = [aws_eks_cluster.production_eks_cluster]
}
resource "helm_release" "kibana" {
  name             = "kibana"
  repository       = "https://helm.elastic.co"
  chart            = "kibana"
  version          = "8.5.1"
  namespace        = "elastic-stack"
  create_namespace = true

  depends_on = [helm_release.elasticsearch]
}

# Fluentd
resource "helm_release" "fluentd" {
  name             = "fluentd"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluentd"
  version          = "0.5.3"
  namespace        = "elastic-stack"
  create_namespace = true

  depends_on = [helm_release.elasticsearch]
}

# Kibana Ingress with TLS
resource "kubernetes_ingress_v1" "kibana_ingress" {
  metadata {
    name      = "kibana-ingress"
    namespace = "elastic-stack"
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"
    
    tls {
      hosts       = ["kibana.shipcodes.tech"]
      secret_name = "kibana-tls"
    }
    
    rule {
      host = "kibana.shipcodes.tech"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kibana-kibana"
              port {
                number = 5601
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.kibana, helm_release.nginx_ingress, helm_release.cert_manager]
}

