terraform {
  backend "s3" {
    bucket = "devops-cluster-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}


