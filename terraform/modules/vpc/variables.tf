variable "project_name" {
  description = "Name used as a prefix for resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range for the VPC."
  type        = string
}

variable "availability_zones1" {
  description = "First availability zone for the VPC."
  type        = string
}

variable "availability_zones2" {
  description = "Second availability zone for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Two public subnet CIDR ranges."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDRs."
  }
}

