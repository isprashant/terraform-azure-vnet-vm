output "repository_names" {
  description = "ECR repository names."
  value       = [for repository in aws_ecr_repository.this : repository.name]
}

output "repository_arns" {
  description = "ECR repository ARNs."
  value       = [for repository in aws_ecr_repository.this : repository.arn]
}

output "repository_urls" {
  description = "ECR repository URLs."
  value       = [for repository in aws_ecr_repository.this : repository.repository_url]
}

output "repositories" {
  description = "ECR repository details keyed by repository name."
  value = {
    for name, repository in aws_ecr_repository.this : name => {
      arn            = repository.arn
      name           = repository.name
      registry_id    = repository.registry_id
      repository_url = repository.repository_url
    }
  }
}

output "full_access_policy_arn" {
  description = "ARN of the IAM policy granting full access to the managed ECR repositories."
  value       = var.create_full_access_policy ? aws_iam_policy.full_access[0].arn : null
}

output "full_access_policy_name" {
  description = "Name of the IAM policy granting full access to the managed ECR repositories."
  value       = var.create_full_access_policy ? aws_iam_policy.full_access[0].name : null
}
