variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment for the project (e.g., dev, staging, prod)."
  type        = string
}

variable "application_port" {
  description = "The port on which the application listens."
  type        = number
  default     = 8080
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be created."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs where the ALB will be deployed."
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate used by the HTTPS listener"
  type        = string
}