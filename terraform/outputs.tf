# terraform/outputs.tf
# Values to display after terraform apply
# These are what you'll copy to GitHub Secrets


# EC2 Information


output "ec2_public_ip" {
  description = "EC2 Public IP - use as EC2_HOST in GitHub Secrets"
  value       = aws_instance.app_server.public_ip
}

output "ec2_public_dns" {
  description = "EC2 Public DNS name"
  value       = aws_instance.app_server.public_dns
}

output "ssh_command" {
  description = "Command to SSH into your EC2"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.app_server.public_ip}"
}


# ECR Repositories


output "ecr_frontend_url" {
  description = "Frontend ECR URL - use as ECR_FRONTEND in GitHub Secrets"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_url" {
  description = "Backend ECR URL - use as ECR_BACKEND in GitHub Secrets"
  value       = aws_ecr_repository.backend.repository_url
}


# AWS Configuration


output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

# GitHub Actions Credentials
# Add these as GitHub Secrets for CI/CD


output "github_actions_access_key_id" {
  description = "AWS_ACCESS_KEY_ID for GitHub Secrets"
  value       = aws_iam_access_key.github_actions.id
}

output "github_actions_secret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY for GitHub Secrets"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}

# Application URLs


output "website_url" {
  description = "URL Shortener website"
  value       = "http://${aws_instance.app_server.public_ip}"
}

output "api_docs_url" {
  description = "FastAPI auto-generated docs"
  value       = "http://${aws_instance.app_server.public_ip}:8000/docs"
}


# Data source for AWS account


data "aws_caller_identity" "current" {}