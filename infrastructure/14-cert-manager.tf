# cert-manager Helm chart.
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "oci://quay.io/jetstack/charts/cert-manager"
  version    = "v1.15.3"
  namespace  = "cert-manager"
  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }

  depends_on = [aws_eks_node_group.eks_node_group]
}

# Let's Encrypt ClusterIssuer
resource "kubectl_manifest" "letsencrypt_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.letsencrypt_email}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
YAML

  depends_on = [helm_release.cert_manager]
}
