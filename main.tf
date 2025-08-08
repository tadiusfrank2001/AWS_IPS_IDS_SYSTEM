# main.tf


# ===== TERRAFORM CONFIGURATION BLOCK =====

# This tells Terraform exactly which "plugins" (called providers) it needs to download and which versions are acceptable.
terraform {
    #
  required_providers {
    # This ensures we are using the AWS provider 
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # This ensures our S3 bucket names are globally unique
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.region
}

# Generate random suffix for unique naming of S3 buckets
resource "random_id" "lab_suffix" {
  byte_length = 4
}






# ===== DATA SOURCES =====

# This allows you to place your EC2s into existing network infrastructure without having to create VPCs/subnets manually.
# Fetches your default VPC, we could customise our VPC but it's not neccessary right now
data "aws_vpc" "default" {
  default = true
}

# Gets all subnets in that default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Get Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Get current AWS region and account, best practice is to avoid hardcoding these fields
# Because we are getting the current identity and region we can deploy this code and build anywhere
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}




# ===== SSH KEY PAIR =====

# Creates a new SSH key pair in AWS using your local public key (.pub). 
# You'll use the private key to SSH into your EC2 instances.
resource "aws_key_pair" "gd_lab_keypair" {
  key_name   = "gd-lab-keypair-${random_id.lab_suffix.hex}"
  public_key = file(var.public_key_path)

  tags = {
    Name = "GuardDuty Lab Key Pair"
  }
}


# ===== SECURITY GROUP =====

# Creates a firewall (security group) for your EC2 instances. 
# It controls what traffic is allowed in (ingress) and out (egress).
resource "aws_security_group" "gd_lab_sg" {
  name        = "gd-lab-sg"
  description = "Security group for GuardDuty lab EC2 Instances"
  vpc_id      = data.aws_vpc.default.id

# The ingress (incoming) traffic will be allowed from your local machine (your public IP) on port 22 (SSH) on the AWS instance.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

# HTTP for malicious communication simulation
  ingress {
    description = "HTTP for threat simulation"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

# The egress (outgoing) traffic will be allowed to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
    Name = "GuardDuty Lab Security Group"
  }
}

# ===== EC2 INSTANCES =====

# Creates a small EC2 instance using the Amazon Linux 2 AMI, which simulates the compromised system. 
# This will be the instance that gets caught making malicious traffic.

# NOTE: t2.micro is free-tier eligible
# Uses first subnet available
# Gets a public IP
# Uses your key pair and security group


# Compromised instance (the victim)
resource "aws_instance" "ec2_compromised" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.gd_lab_keypair.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.gd_lab_sg.id]
  associate_public_ip_address = true

# run a bash script on first boot to update operating system and install curl binary
user_data = file("${path.module}/scripts/setup_server.sh")

  tags = {
    Name = "EC2-Compromised"
    Type = "Victim"
  }
}





