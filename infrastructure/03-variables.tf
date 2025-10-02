variable "region" {
  type = string
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "eks_cluster_name" {
  type = string
  default = "production_eks"
}

variable "letsencrypt_email" {
  type = string
  description = "Email address for Let's Encrypt certificates"
  default = "muthurikennedy082@gmail.com"
}
