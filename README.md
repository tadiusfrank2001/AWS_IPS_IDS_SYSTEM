# AWS GuardDuty Security Lab 🛡️

A hands-on Terraform project that creates a realistic AWS security lab environment to demonstrate threat detection, incident response, and automated security remediation using AWS GuardDuty.

## 🎯 Purpose

This project was created to deepen my understanding of AWS security services and practice building automated incident response systems. It simulates a real-world scenario where a compromised EC2 instance communicates with a known malicious IP address, triggering GuardDuty alerts and automated remediation.

## 🏗️ Architecture Overview

The lab creates a complete security monitoring and response pipeline:

- **Two EC2 instances**: One "compromised" victim and one "malicious" attacker
- **GuardDuty**: Monitors for suspicious network activity and threats
- **Custom Threat Intelligence**: S3-hosted threat list with the attacker's IP
- **Automated Response**: Lambda function that stops compromised instances
- **Alerting**: SNS notifications for security events
- **Centralized Monitoring**: Security Hub integration


---

## 🧰 AWS Services Used

| Category       | Service         | Purpose                               |
|----------------|------------------|----------------------------------------|
| Compute        | EC2              | Launch victim & attacker instances     |
| Networking     | VPC, Elastic IP  | Enable public/static IP traffic        |
| Storage        | S3               | Host threat list                       |
| Security       | GuardDuty        | Detect malicious behavior              |
| Monitoring     | Security Hub     | Centralize security findings           |
| Alerts         | SNS              | Optional alerting                      |
| Automation     | Lambda           | Auto-remediate compromised instance    |
| Event-driven   | EventBridge      | Trigger Lambda on GuardDuty finding    |
| IAM            | IAM              | Secure permissions for automation      |

---

## 🚀 Features

### Security Monitoring
- **Real-time threat detection** with AWS GuardDuty
- **Custom threat intelligence** integration via S3
- **Multi-service monitoring** including EC2, S3, and network activity

### Automated Response
- **Incident isolation** - automatically stops compromised instances
- **Email notifications** for security events
- **EventBridge integration** for real-time event processing

### Lab Environment
- **Realistic attack simulation** between EC2 instances
- **Different AMI types** (Amazon Linux 2 vs 2023) for variety
- **Proper network segmentation** using VPC subnets
- **Security groups** configured for controlled access

## 📋 Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- python modules bot3, json, and os installed
- An SSH key pair generated (`ssh-keygen -t rsa -b 2048`)
- Your public IP address for secure SSH access

---


## 🛠️ Quick Start

1. **Clone and configure**:
   ```bash
   git clone <your-repo-url>
   cd guardduty-security-lab
   ```

2. **Create your variables file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edit `terraform.tfvars` with your values:
   ```hcl
   aws_access_key    = "your-access-key"
   aws_secret_key    = "your-secret-key"
   region           = "us-east-1"
   my_ip            = "YOUR.PUBLIC.IP.ADDRESS/32"
   public_key_path  = "~/.ssh/id_rsa.pub"
   alert_email      = "your-email@example.com"
   ```

3. **Deploy the infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Confirm SNS subscription** in your email