locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
    },
    var.tags
  )

  repository_arns = [
    for repository in aws_ecr_repository.this : repository.arn
  ]
}
