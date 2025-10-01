# EKS Cluster IAM Role
resource "aws_iam_role" "production_eks_role" {
  name = "production_eks_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "production_eks_role"
    Environment = "production"
  }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.production_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}



# EKS Cluster
resource "aws_eks_cluster" "production_eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.production_eks_role.arn
  version  = "1.33"

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = concat(aws_subnet.production_private_subnet[*].id, aws_subnet.production_public_subnet[*].id)
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  
  bootstrap_self_managed_addons = true

  upgrade_policy {
    support_type = "STANDARD"
  }

  tags = {
    Name        = var.eks_cluster_name
    Environment = "production"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

