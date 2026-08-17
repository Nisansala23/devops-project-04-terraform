# terraform/iam.tf
# IAM = Identity and Access Management
# Controls WHO can do WHAT in AWS


# PART 1: EC2 ROLE
# EC2 needs permission to pull images from ECR


# Create an IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # Trust policy - who can use this role?
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach AWS-managed policy: allow reading from ECR
resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Instance profile - wrapper needed to attach role to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# PART 2: GITHUB ACTIONS USER
# GitHub Actions needs permission to push to ECR


# Create IAM User for GitHub Actions
resource "aws_iam_user" "github_actions" {
  name = "${var.project_name}-github-actions"

  tags = {
    Name        = "GitHub Actions CI/CD User"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Policy - allow pushing/pulling to ECR
resource "aws_iam_user_policy" "github_actions_policy" {
  name = "${var.project_name}-github-actions-policy"
  user = aws_iam_user.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ]
      Resource = "*"
    }]
  })
}

# Create access keys (for GitHub Secrets)
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}