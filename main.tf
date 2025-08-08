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

