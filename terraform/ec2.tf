# terraform/ec2.tf
# The actual server that runs our app


# Find latest Amazon Linux 2023 AMI


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# SSH Key Pair
# Uploads your public key to AWS


resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Name        = "${var.project_name}-key"
    Environment = var.environment
    Project     = var.project_name
  }
}


# EC2 Instance
# The actual server


resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Bootstrap script - runs when EC2 first starts
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    dnf update -y

    # Install Docker
    dnf install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Install Docker Compose (v2 plugin)
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
      -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    # Create app directory
    mkdir -p /home/ec2-user/app
    chown ec2-user:ec2-user /home/ec2-user/app

    # Signal that setup is done
    echo "Bootstrap complete at $(date)" > /tmp/bootstrap-done.txt
  EOF

  tags = {
    Name        = "${var.project_name}-server"
    Environment = var.environment
    Project     = var.project_name
  }
}