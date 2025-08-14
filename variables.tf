


# ==== AWS REGION ====
variable "region" {
  description = "AWS region to deploy all resources"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1)."
  }
}



# ==== PUBLIC KEY PATH ====

variable "public_key_path" {
  description = "Path to your SSH public key file (e.g., ~/.ssh/id_rsa.pub)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"

  validation {
    condition     = can(file(var.public_key_path))
    error_message = "The public key file must exist at the specified path."
  }
}


# ===== LOCAL MACHINE IP =====

variable "my_ip" {
  description = "Your public IP address in CIDR format (e.g., 203.0.113.45/32). Use 'curl ifconfig.me' to find your IP."
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip, 0))
    error_message = "The my_ip value must be a valid CIDR block (e.g., 203.0.113.45/32)."
  }
}




# ===== ALERT EMAIL =====

variable "alert_email" {
  description = "Email address to receive GuardDuty security alerts"
  type        = string

  validation {
    condition     = can(regex("^[\\w\\.-]+@[\\w\\.-]+\\.[a-zA-Z]{2,}$", var.alert_email))
    error_message = "The alert_email must be a valid email address format."
  }
}




