terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubectl = {
      source = "bnu0/kubectl"
      version = "0.27.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Helm Provider
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.production_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.production_eks_cluster.certificate_authority[0].data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["eks", "get-token", "--cluster-name", aws_eks_cluster.production_eks_cluster.name]
    }
  }
}

# Kubectl Provider
provider "kubectl" {
  apply_retry_count      = 15
  host                   = aws_eks_cluster.production_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.production_eks_cluster.certificate_authority[0].data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      aws_eks_cluster.production_eks_cluster.name,
    ]
  }
}

# Kubernetes Provider
provider "kubernetes" {
  host                   = aws_eks_cluster.production_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.production_eks_cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", aws_eks_cluster.production_eks_cluster.name]
  }
}

