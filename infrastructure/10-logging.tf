# Elasticsearch - With fresh storage
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.17.3"
  namespace  = "elastic-stack"
  create_namespace = true
  timeout    = 600

  # Force new storage
  set {
    name  = "persistence.enabled"
    value = "false"  # Use emptyDir instead of persistent storage
  }

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "minimumMasterNodes"
    value = "1"
  }

  set {
    name  = "esConfig.elasticsearch\\.yml"
    value = "xpack.security.enabled: false"
  }

  # This ensures we get a fresh start
  force_update = true
}

# Kibana - Keep as is
resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.17.3"
  namespace  = "elastic-stack"

  depends_on = [helm_release.elasticsearch]
}

# Fluent Bit - Keep as is
resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "elastic-stack"
  timeout    = 300 

  set {
    name  = "resources.requests.cpu"
    value = "1m"  
  }

  set {
    name  = "resources.requests.memory"
    value = "10Mi" 
  }

  set {
    name  = "resources.limits.memory"
    value = "50Mi"  
  }

  set {
    name  = "config.outputs"
    value = "[OUTPUT]\n    Name es\n    Match *\n    Host elasticsearch-master\n    Port 9200\n    Logstash_Format On\n    Logstash_Prefix kubernetes\n    Retry_Limit False"
  }

  depends_on = [helm_release.elasticsearch]
}

# Kibana Ingress - Keep as is
resource "kubernetes_ingress_v1" "kibana" {
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

  depends_on = [helm_release.kibana]
}