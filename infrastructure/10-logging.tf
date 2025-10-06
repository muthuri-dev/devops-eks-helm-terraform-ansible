# Namespace for logging stack
resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

# Elasticsearch using Helm
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  version    = "7.17.3"
  timeout    = 600

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "minimumMasterNodes"
    value = "1"
  }

  set {
    name  = "resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "500m"
  }

  set {
    name  = "resources.limits.memory"
    value = "1Gi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = "10Gi"
  }

  set {
    name  = "volumeClaimTemplate.storageClassName"
    value = "gp2"
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "esJavaOpts"
    value = "-Xmx512m -Xms512m"
  }

  values = [
    yamlencode({
      esConfig = {
        "elasticsearch.yml" = "xpack.security.enabled: false\n"
      }
    })
  ]

  depends_on = [ kubernetes_namespace.logging ]
}

# Kibana using Helm
resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  version    = "7.17.3"

  set {
    name  = "elasticsearchHosts"
    value = "http://elasticsearch-master:9200"
  }

  set {
    name  = "resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "250m"
  }

  set {
    name  = "resources.limits.memory"
    value = "1Gi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }

  depends_on = [helm_release.elasticsearch]
}

# Fluent Bit for log collection
resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  version    = "0.43.0"

  values = [
    yamlencode({
      config = {
        outputs = <<-EOT
          [OUTPUT]
              Name es
              Match kube.*
              Host elasticsearch-master.${kubernetes_namespace.logging.metadata[0].name}.svc.cluster.local
              Port 9200
              Logstash_Format On
              Logstash_Prefix kubernetes
              Retry_Limit 5
              Suppress_Type_Name On
        EOT
      }
    })
  ]

  depends_on = [helm_release.elasticsearch]
}


# Kibana Ingress
resource "kubernetes_ingress_v1" "kibana_ingress" {
  metadata {
    name      = "kibana-ingress"
    namespace = kubernetes_namespace.logging.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "false"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
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

  depends_on = [
    helm_release.kibana
  ]
}

