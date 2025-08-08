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
user_data = file("${path.module}/scripts/compromised_server_setup.sh")

  tags = {
    Name = "EC2-Compromised"
    Type = "Victim"
  }
}


# Creates a small EC2 instance using the Amazon Linux AMI 2023, which simulates the attacker system.
# Placed in a different subnet in VPC for separation

# Malicious instance (the attacker)
resource "aws_instance" "ec2_malicious" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.gd_lab_keypair.key_name
  subnet_id                   = length(data.aws_subnets.default.ids) > 1 ? data.aws_subnets.default.ids[1] : data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.gd_lab_sg.id]
  associate_public_ip_address = true

# Run a bash script to update operating system, install Python, run a http server on port 80
 user_data = file("${path.module}/scripts/malicious_server_setup.sh")

  tags = {
    Name = "EC2-Malicious"
    Type = "Attacker"
  }
}

# Elastic IP for malicious instance (this becomes our "known threat IP")
resource "aws_eip" "malicious_ip" {
  instance = aws_instance.ec2_malicious.id
  domain   = "vpc"

  tags = {
    Name = "Malicious Threat IP"
  }
}








# ===== S3 BUCKET FOR THREAT LIST =====

# Creates an S3 bucket for the GuardDuty lab with a globally unique identifier
resource "aws_s3_bucket" "gd_lab_bucket" {
  bucket = "gd-lab-bucket-${random_id.lab_suffix.hex}"

  tags = {
    Name        = "GuardDuty Lab Bucket"
    Environment = "Lab"
  }
}

# Block public access (except what we explicitly allow via policy)
resource "aws_s3_bucket_public_access_block" "gd_threat_list_pab" {
  bucket = aws_s3_bucket.gd_threat_list.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy allowing GuardDuty to read the threat list
resource "aws_s3_bucket_policy" "gd_threat_list_policy" {
  bucket = aws_s3_bucket.gd_threat_list.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGuardDutyReadAccess"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.gd_threat_list.arn}/threatlist.txt"
      }
    ]
  })

   depends_on = [aws_s3_bucket_public_access_block.gd_threat_list_pab]
}

# Create the threatlist.txt file with the malicious IP automatically
resource "aws_s3_object" "threat_list" {
  bucket       = aws_s3_bucket.gd_threat_list.id
  key          = "threatlist.txt"
  content      = aws_eip.malicious_ip.public_ip
  content_type = "text/plain"

  tags = {
    Name = "Threat Intelligence List"
  }

  depends_on = [aws_eip.malicious_ip]
}











# ===== S3 BUCKET FOR THREAT LIST =====

# Creates an S3 bucket for the GuardDuty lab with a globally unique identifier
resource "aws_s3_bucket" "gd_lab_bucket" {
  bucket = "gd-lab-bucket-${random_id.lab_suffix.hex}"

  tags = {
    Name        = "GuardDuty Lab Bucket"
    Environment = "Lab"
  }
}

# Block public access (except what we explicitly allow via policy)
resource "aws_s3_bucket_public_access_block" "gd_threat_list_pab" {
  bucket = aws_s3_bucket.gd_threat_list.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy allowing GuardDuty to read the threat list
resource "aws_s3_bucket_policy" "gd_threat_list_policy" {
  bucket = aws_s3_bucket.gd_threat_list.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGuardDutyReadAccess"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.gd_threat_list.arn}/threatlist.txt"
      }
    ]
  })

   depends_on = [aws_s3_bucket_public_access_block.gd_threat_list_pab]
}

# Create the threatlist.txt file with the malicious IP automatically
resource "aws_s3_object" "threat_list" {
  bucket       = aws_s3_bucket.gd_threat_list.id
  key          = "threatlist.txt"
  content      = aws_eip.malicious_ip.public_ip
  content_type = "text/plain"

  tags = {
    Name = "Threat Intelligence List"
  }

  depends_on = [aws_eip.malicious_ip]
}













# ===== GUARDDUTY =====

# Enable GuardDuty detector
resource "aws_guardduty_detector" "gd_lab_detector" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = false
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = {
    Name = "GuardDuty Lab Detector"
  }
}

# Configure GuardDuty to use our custom threat list
resource "aws_guardduty_threatintelset" "gd_threat_intel" {
  activate    = true
  detector_id = aws_guardduty_detector.gd_lab_detector.id
  format      = "TXT"
  location    = "https://${aws_s3_bucket.gd_threat_list.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/threatlist.txt"
  name        = "Lab Threat Intelligence"

  depends_on = [
    aws_s3_object.threat_list,
    aws_s3_bucket_policy.gd_threat_list_policy
  ]
}








# ===== SECURITY HUB =====

# Enable Security Hub to aggregate GuardDuty findings
resource "aws_securityhub_account" "gd_lab_security_hub" {
  enable_default_standards = true

  depends_on = [aws_guardduty_detector.gd_lab_detector]
}









# ===== SNS FOR ALERTS =====

# SNS topic for sending security alerts
resource "aws_sns_topic" "gd_lab_alerts" {
  name = "gd-lab-alerts-${random_id.lab_suffix.hex}"

  tags = {
    Name = "GuardDuty Lab Alerts"
  }
}

# Email subscription to SNS topic (requires manual confirmation)
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.gd_lab_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}



















