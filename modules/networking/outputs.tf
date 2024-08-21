output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "aurora_security_group_id" {
  description = "Security group ID for the Aurora cluster"
  value       = aws_security_group.aurora.id
}

output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "crawler_security_group_id" {
  description = "Security group ID for the crawler app"
  value       = aws_security_group.crawler.id
}
