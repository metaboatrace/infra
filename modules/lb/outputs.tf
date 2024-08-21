output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "crawler_target_group_arn" {
  description = "The ARN of the target group associated with the load balancer for backend"
  value       = aws_lb_target_group.crawler.arn
}
