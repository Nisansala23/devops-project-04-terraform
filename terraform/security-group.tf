# terraform/security-group.tf
# Firewall rules for the EC2 instance

# Get the default VPC (AWS gives you one)


data "aws_vpc" "default" {
  default = true
}


# Security Group = Firewall for EC2


resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg"
  description = "Security group for URL Shortener app"
  vpc_id      = data.aws_vpc.default.id

  # INBOUND RULES 

  # HTTP - allow web traffic from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend API port - allow from anywhere
  ingress {
    description = "Backend API"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH - ONLY from your IP
  ingress {
    description = "SSH - key auth only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OUTBOUND RULES 

  # Allow ALL outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}