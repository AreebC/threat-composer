variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment for the project (e.g., dev, staging, prod)."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be created."
  type        = string
}

variable "application_port" {
  description = "The port on which the application listens."
  type        = number
  default     = 8080
}

variable "alb_security_group_id" {
  description = "The ID of the security group to associate with the ALB."
  type        = string
}

variable "task_cpu" {
  description = "The number of CPU units to allocate for the ECS task."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "The amount of memory (in MiB) to allocate for the ECS task."
  type        = number
  default     = 512
}

variable "container_image" {
  description = "The Docker image to use for the ECS container."
  type        = string
}

variable "container_name" {
  description = "The name of the ECS container."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
}

variable "desired_task_count" {
  description = "The desired number of ECS tasks to run."
  type        = number
  default     = 1
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs where the ECS tasks will be deployed."
  type        = list(string)
}

variable "target_group_arn" {
  description = "The ARN of the target group to associate with the ECS service."
  type        = string
}


