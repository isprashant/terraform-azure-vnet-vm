variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name used for resource names and tags."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the NLB target group is created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the Network Load Balancer."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two subnet IDs for the Network Load Balancer."
  }
}

variable "eks_node_group_autoscaling_group_names" {
  description = "Auto Scaling Group names backing the EKS managed node groups."
  type        = list(string)

  validation {
    condition     = length(var.eks_node_group_autoscaling_group_names) >= 1
    error_message = "Provide at least one EKS node group Auto Scaling Group name."
  }
}

variable "internal" {
  description = "Whether the NLB is internal."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Whether deletion protection is enabled for the NLB."
  type        = bool
  default     = false
}

variable "listener_port" {
  description = "NLB listener port."
  type        = number
  default     = 80
}

variable "target_port" {
  description = "Port on the EKS worker nodes that receives traffic, usually a Kubernetes NodePort."
  type        = number
  default     = 30080
}

variable "health_check_port" {
  description = "Health check port. Use traffic-port to use the target group port."
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Health check protocol for the target group."
  type        = string
  default     = "TCP"
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
