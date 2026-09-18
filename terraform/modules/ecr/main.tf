resource "aws_ecr_repository" "main" {
  name = "${var.project_name}-${var.environment}"

  # Prevent an existing image tag from being overwritten.
  image_tag_mutability = "IMMUTABLE"

  # Scan images for vulnerabilities when they are pushed.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Encrypt the container images stored in ECR.
  encryption_configuration {
    encryption_type = "AES256"
  }

  # Allows Terraform to delete the repository during development,
  # even when it contains images.
  force_delete = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ecr"
  }
}