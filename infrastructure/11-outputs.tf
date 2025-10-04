
output "endpoint" {
  value = aws_eks_cluster.production_eks_cluster.endpoint
}

# ECR Repository Output
output "ecr_repository" {
  description = "ECR repository information"
  value = {
    name           = aws_ecr_repository.app.name
    repository_url = aws_ecr_repository.app.repository_url
    arn            = aws_ecr_repository.app.arn
  }
}

output "ecr_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.registry_id}.dkr.ecr.${var.region}.amazonaws.com"
}

# CloudNativePG Output
output "postgres_operator_status" {
  description = "Check CloudNativePG operator status"
  value       = "kubectl get pods -n cnpg-system"
}

# Cert-Manager Output
output "cert_manager_status" {
  description = "Check cert-manager status"
  value       = "kubectl get pods -n cert-manager"
}

# Vault Output
output "vault_status" {
  description = "Check Vault status"
  value       = "kubectl get pods -n vault"
}


# Output the ingress controller load balancer hostname
output "ingress_controller_hostname" {
  description = "Hostname of the ingress controller load balancer"
  value       = "Run: kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}