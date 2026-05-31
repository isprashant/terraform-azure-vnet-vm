output "nlb_arn" {
  description = "ARN of the Network Load Balancer."
  value       = aws_lb.this.arn
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer."
  value       = aws_lb.this.dns_name
}

output "nlb_zone_id" {
  description = "Canonical hosted zone ID of the Network Load Balancer."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the NLB target group."
  value       = aws_lb_target_group.this.arn
}

output "listener_arn" {
  description = "ARN of the NLB listener."
  value       = aws_lb_listener.this.arn
}
