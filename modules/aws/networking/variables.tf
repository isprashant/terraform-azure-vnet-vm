variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name used for resource names and tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "Provide at least two public subnet CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "Provide at least two private subnet CIDR blocks."
  }
}

variable "availability_zones" {
  description = "Availability zones where the public and private subnets will be created."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Provide at least two Availability Zones."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
