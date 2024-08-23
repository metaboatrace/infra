output "aurora_cluster_endpoint" {
  description = "The endpoint of the Aurora cluster"
  value       = module.database.aurora_cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "The reader endpoint of the Aurora cluster"
  value       = module.database.aurora_cluster_reader_endpoint
}

output "load_balancer_dns" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.lb.load_balancer_dns
}
