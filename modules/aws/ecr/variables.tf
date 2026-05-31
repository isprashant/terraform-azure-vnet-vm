variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name used for resource names and tags."
  type        = string
}

variable "repository_names" {
  description = "ECR repository names to create. Names may include namespaces, for example microapps/auth-service."
  type        = list(string)

  validation {
    condition     = length(var.repository_names) > 0
    error_message = "Provide at least one ECR repository name."
  }
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting for ECR repositories."
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "force_delete" {
  description = "Whether to delete images automatically when destroying repositories."
  type        = bool
  default     = true
}

variable "scan_on_push" {
  description = "Whether ECR scans images when they are pushed."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "ECR encryption type."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be AES256 or KMS."
  }
}

variable "kms_key" {
  description = "KMS key ARN or alias for ECR encryption when encryption_type is KMS."
  type        = string
  default     = null
}

variable "enable_lifecycle_policy" {
  description = "Whether to attach lifecycle cleanup policies to the repositories."
  type        = bool
  default     = true
}

variable "untagged_image_expire_days" {
  description = "Number of days after which untagged images are expired."
  type        = number
  default     = 7
}

variable "max_tagged_image_count" {
  description = "Number of tagged images to keep per repository."
  type        = number
  default     = 30
}

variable "create_full_access_policy" {
  description = "Whether to create an IAM policy with full access to these repositories."
  type        = bool
  default     = true
}

variable "full_access_policy_name" {
  description = "Optional IAM policy name. Defaults to project-environment-ecr-full-access."
  type        = string
  default     = null
}

variable "full_access_iam_user_names" {
  description = "IAM user names to attach the full access ECR policy to."
  type        = list(string)
  default     = []
}

variable "full_access_iam_role_names" {
  description = "IAM role names to attach the full access ECR policy to."
  type        = list(string)
  default     = []
}

variable "full_access_iam_group_names" {
  description = "IAM group names to attach the full access ECR policy to."
  type        = list(string)
  default     = []
}

variable "repository_full_access_principal_arns" {
  description = "AWS principal ARNs to grant full access through ECR repository policies."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
