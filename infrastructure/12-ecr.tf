# Amazon ECR (Elastic Container Registry) 

resource "aws_ecr_repository" "app" {
  name                 = "golang-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "golang-app"
    Environment = "production"
  }
}


