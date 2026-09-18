output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for the Application Load Balancer."
  value       = module.vpc.public_subnet_ids
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "URL used to push and pull Docker images"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "alb_dns_name" {
  description = "Public address used to access the application"
  value       = module.alb.alb_dns_name
}

output "alb_security_group_id" {
  description = "Security group attached to the ALB"
  value       = module.alb.alb_security_group_id
}

output "alb_target_group_arn" {
  description = "Target group used by the ECS service"
  value       = module.alb.target_group_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "ecs_security_group_id" {
  description = "Security group attached to ECS tasks"
  value       = module.ecs.ecs_security_group_id
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group containing application logs"
  value       = module.ecs.cloudwatch_log_group_name
}
