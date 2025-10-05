# EBS CSI Driver for EKS 

# IAM role for EBS CSI driver
resource "aws_iam_role" "ebs_csi_role" {
  name = "EKS_EBS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach the required policy to the EBS CSI role
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role.name
}

# EBS CSI driver addon
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.production_eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.48.0-eksbuild.2"
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn
  
  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}

# OIDC provider for EKS (required for service account authentication)
data "tls_certificate" "eks" {
  url = aws_eks_cluster.production_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.production_eks_cluster.identity[0].oidc[0].issuer
}