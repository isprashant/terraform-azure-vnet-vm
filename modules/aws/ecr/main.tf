resource "aws_ecr_repository" "this" {
  for_each = toset(var.repository_names)

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key
  }

  tags = merge(
    local.common_tags,
    {
      Name = each.value
    }
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.enable_lifecycle_policy ? aws_ecr_repository.this : {}

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after ${var.untagged_image_expire_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expire_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep the last ${var.max_tagged_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_tagged_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "full_access" {
  count = var.create_full_access_policy ? 1 : 0

  statement {
    sid = "AllowEcrAuthorizationToken"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowRepositoryFullAccess"

    actions = [
      "ecr:*"
    ]

    resources = local.repository_arns
  }
}

resource "aws_iam_policy" "full_access" {
  count = var.create_full_access_policy ? 1 : 0

  name        = coalesce(var.full_access_policy_name, "${local.name_prefix}-ecr-full-access")
  description = "Full ECR permissions for repositories managed by ${local.name_prefix}."
  policy      = data.aws_iam_policy_document.full_access[0].json

  tags = local.common_tags
}

resource "aws_iam_user_policy_attachment" "full_access" {
  for_each = var.create_full_access_policy ? toset(var.full_access_iam_user_names) : toset([])

  user       = each.value
  policy_arn = aws_iam_policy.full_access[0].arn
}

resource "aws_iam_role_policy_attachment" "full_access" {
  for_each = var.create_full_access_policy ? toset(var.full_access_iam_role_names) : toset([])

  role       = each.value
  policy_arn = aws_iam_policy.full_access[0].arn
}

resource "aws_iam_group_policy_attachment" "full_access" {
  for_each = var.create_full_access_policy ? toset(var.full_access_iam_group_names) : toset([])

  group      = each.value
  policy_arn = aws_iam_policy.full_access[0].arn
}

data "aws_iam_policy_document" "repository_full_access" {
  for_each = length(var.repository_full_access_principal_arns) > 0 ? aws_ecr_repository.this : {}

  statement {
    sid = "AllowPrincipalFullRepositoryAccess"

    principals {
      type        = "AWS"
      identifiers = var.repository_full_access_principal_arns
    }

    actions = [
      "ecr:*"
    ]
  }
}

resource "aws_ecr_repository_policy" "full_access" {
  for_each = length(var.repository_full_access_principal_arns) > 0 ? aws_ecr_repository.this : {}

  repository = each.value.name
  policy     = data.aws_iam_policy_document.repository_full_access[each.key].json
}
