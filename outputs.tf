# ALB DNS (to access your app)
output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.flashmind.dns_name
}

# RDS Endpoint (used internally in your app)
output "rds_endpoint" {
  description = "Endpoint address of the RDS Postgres instance"
  value       = aws_db_instance.flashmind.address
}

# ECS Task Definition
output "ecs_task_definition" {
  description = "ECS Task Definition ARN"
  value       = aws_ecs_task_definition.flashmind.arn
}

# VPC ID
output "vpc_id" {
  description = "The ID of the main VPC"
  value       = aws_vpc.main.id
}
