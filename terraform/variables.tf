# terraform/variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name - used as prefix for all resources"
  type        = string
  default     = "url-shortener"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "ec2_instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "Your IP address for SSH access (format: x.x.x.x/32)"
  type        = string
  # No default - must provide in terraform.tfvars
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "urlshortener"
}

variable "db_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "urluser"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
  # No default - must provide in terraform.tfvars
}