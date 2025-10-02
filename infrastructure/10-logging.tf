
# ELK Stack using ECK (Elastic Cloud on Kubernetes) 
# ECK operator
resource "helm_release" "eck_operator" {
  name             = "elastic-operator"
  repository       = "https://helm.elastic.co"
  chart            = "eck-operator"
  namespace        = "elastic-system"
  create_namespace = true

  depends_on = [aws_eks_cluster.production_eks_cluster]
}

# Elasticsearch cluster using kubectl provider
resource "kubectl_manifest" "elasticsearch" {
  yaml_body = yamlencode({
    apiVersion = "elasticsearch.k8s.elastic.co/v1"
    kind       = "Elasticsearch"
    metadata = {
      name      = "elasticsearch"
      namespace = "elastic-stack"
    }
    spec = {
      version = "8.5.1"
      nodeSets = [
        {
          name  = "default"
          count = 1
          config = {
            "node.store.allow_mmap"                = false
            "xpack.security.enabled"              = false
            "xpack.security.enrollment.enabled"   = false
            "xpack.security.http.ssl.enabled"     = false
            "xpack.security.transport.ssl.enabled" = false
          }
          volumeClaimTemplates = [
            {
              metadata = {
                name = "elasticsearch-data"
              }
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "5Gi"
                  }
                }
                storageClassName = "gp2"
              }
            }
          ]
          podTemplate = {
            spec = {
              containers = [
                {
                  name = "elasticsearch"
                  resources = {
                    limits = {
                      memory = "2Gi"
                      cpu    = "1"
                    }
                    requests = {
                      memory = "1Gi"
                      cpu    = "500m"
                    }
                  }
                }
              ]
            }
          }
        }
      ]
      http = {
        service = {
          spec = {
            type = "ClusterIP"
          }
        }
      }
    }
  })

  depends_on = [helm_release.eck_operator]
}

# Create namespace first
resource "kubernetes_namespace" "elastic_stack" {
  metadata {
    name = "elastic-stack"
  }
}

# Kibana deployment using kubectl provider
resource "kubectl_manifest" "kibana" {
  yaml_body = yamlencode({
    apiVersion = "kibana.k8s.elastic.co/v1"
    kind       = "Kibana"
    metadata = {
      name      = "kibana"
      namespace = "elastic-stack"
    }
    spec = {
      version = "8.5.1"
      count   = 1
      elasticsearchRef = {
        name = "elasticsearch"
      }
      config = {
        "server.publicBaseUrl"            = "http://localhost:5601"
        "elasticsearch.ssl.verificationMode" = "none"
        "elasticsearch.hosts"             = ["http://elasticsearch-es-http:9200"]
      }
      podTemplate = {
        spec = {
          containers = [
            {
              name = "kibana"
              resources = {
                limits = {
                  memory = "1Gi"
                  cpu    = "500m"
                }
                requests = {
                  memory = "512Mi"
                  cpu    = "200m"
                }
              }
            }
          ]
        }
      }
      http = {
        service = {
          spec = {
            type = "LoadBalancer"
          }
        }
      }
    }
  })

  depends_on = [kubectl_manifest.elasticsearch, kubernetes_namespace.elastic_stack]
}

# Fluent Bit for log collection (compatible with ECK)
resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.com/helm-charts"
  chart      = "fluent-bit"
  namespace  = "elastic-stack"

  values = [
    yamlencode({
      config = {
        service = <<-EOF
          [SERVICE]
              Daemon Off
              Flush 1
              Log_Level info
              Parsers_File /fluent-bit/etc/parsers.conf
              HTTP_Server On
              HTTP_Listen 0.0.0.0
              HTTP_Port 2020
        EOF
        
        inputs = <<-EOF
          [INPUT]
              Name tail
              Path /var/log/containers/*.log
              multiline.parser docker, cri
              Tag kube.*
              Mem_Buf_Limit 50MB
              Skip_Long_Lines On
        EOF
        
        outputs = <<-EOF
          [OUTPUT]
              Name es
              Match *
              Host elasticsearch-es-http
              Port 9200
              Index fluent-bit
              Type _doc
              Suppress_Type_Name On
              Retry_Limit False
        EOF
      }
      
      # Basic resources
      resources = {
        requests = {
          cpu = "50m"
          memory = "64Mi"
        }
        limits = {
          cpu = "100m"
          memory = "128Mi"
        }
      }
    })
  ]

  depends_on = [kubectl_manifest.elasticsearch, kubernetes_namespace.elastic_stack]
}

