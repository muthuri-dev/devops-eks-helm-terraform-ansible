# Service Account for Cluster Autoscaler with IRSA
resource "aws_iam_role" "cluster_autoscaler" {
  name = "cluster-autoscaler"

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
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Minimal IAM policy for autoscaling
resource "aws_iam_role_policy" "cluster_autoscaler" {
  name = "cluster-autoscaler"
  role = aws_iam_role.cluster_autoscaler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# Deploy Cluster Autoscaler using YAML manifest  
resource "kubectl_manifest" "cluster_autoscaler" {
  for_each = data.kubectl_file_documents.cluster_autoscaler.manifests
  yaml_body = each.value
  
  depends_on = [
    aws_iam_role.cluster_autoscaler,
    aws_iam_role_policy.cluster_autoscaler
  ]
}

data "kubectl_file_documents" "cluster_autoscaler" {
  content = file("${path.module}/cluster-autoscaler-deployment.yaml")
}