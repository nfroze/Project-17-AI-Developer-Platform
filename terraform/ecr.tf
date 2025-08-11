resource "aws_ecr_repository" "cost_tracker" {
  name         = "gpu-cost-tracker"
  force_delete = true  # Allow deletion even with images

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Service     = "cost-tracker"
    Platform    = "ecs"
    Environment = var.environment
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.cost_tracker.repository_url
}