variable "aws_region" {
  description = "AWS region in which to create the infrastructure."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Short name used to identify and tag project resources."
  type        = string
  default     = "cloud-threat-composer"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones1" {
  description = "First availability zone for the VPC."
  type        = string
  default     = "us-east-1a"
}

variable "availability_zones2" {
  description = "Second availability zone for the VPC."
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for the public ALB subnets."
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
}

variable "image_tag" {
  description = "Docker image tag that ECS should deploy"
  type        = string
  default     = "bootstrap"
}