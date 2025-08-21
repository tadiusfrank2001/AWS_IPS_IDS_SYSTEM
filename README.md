# AWS GuardDuty Security Simulation 🛡️

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
   region           = "us-east-1"
   my_ip            = "YOUR.PUBLIC.IP.ADDRESS/32"
   public_key_path  = "~/.ssh/id_rsa.pub"
   alert_email      = "your-email@example.com"
   ```
4. **AWS Credentials**

   Download aws cli and Create a file to store credentials so terraform can access them
   
   ```hcl
   mkdir -p ~/.aws
   nano ~/.aws/credentials
   ```

   Open file and store access key and secret for secure access NEVER HARD CODE ANYTHING!!!!
   
```in
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```


3. **Deploy the infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Confirm SNS subscription** in your email

---

## 🧪 Running the Lab

### Trigger GuardDuty Detection

1. **SSH into the compromised instance**:
   ```bash
   ssh -i ~/.ssh/id_rsa ec2-user@<compromised-instance-ip>
   ```

2. **Simulate malicious communication**:
   ```bash
   # This will trigger GuardDuty alerts
   curl http://<malicious-instance-private-ip>
   ```

3. **Monitor the response**:
   - Check GuardDuty console for findings
   - Wait for email alerts from SNS
   - Verify instance auto-stop in EC2 console

### Expected GuardDuty Findings

- **UnauthorizedAPI:EC2/TorIPCaller** (if using Tor-like IPs)
- **CryptoCurrency:EC2/BitcoinTool.B!DNS** (Bitcoin-related DNS queries)
- **Trojan:EC2/BlackholeTraffic** (Communication with known bad IPs)
- **Custom threat intelligence matches**

## 📁 Project Structure

```
.
├── main.tf                          # Main Terraform configuration
├── variables.tf                     # Input variables
├── outputs.tf                       # Output values
├── terraform.tfvars.example         # Example variables file
├── scripts/
│   ├── compromised_server_setup.sh  # Victim instance setup
│   ├── malicious_server_setup.sh    # Attacker instance setup
│   └── lambda_function.py           # Automated response function
└── README.md                        # This file
```

---
## 🔧 Key Components

### Security Groups
- **SSH access** restricted to your IP only
- **HTTP access** allowed between instances for simulation
- **Outbound access** permitted for software updates

### Lambda Function
- **Python 3.12** runtime for modern compatibility
- **Automatic instance stopping** on high-severity findings
- **SNS integration** for immediate notifications
- **CloudWatch logging** for debugging

### Threat Intelligence
- **S3-hosted threat list** with malicious IPs
- **Automatic GuardDuty integration**
- **Dynamic IP updates** via Terraform

## 💰 Cost Considerations

This lab uses mostly free-tier eligible resources:
- **EC2**: t2.micro and t3.micro instances
- **GuardDuty**: 30-day free trial, then pay-per-usage
- **Lambda**: Generous free tier
- **S3**: Minimal storage costs
- **SNS**: First 1,000 notifications free

**Estimated monthly cost**: $10-25 (after free tier)

----

## 🧹 Cleanup

To avoid ongoing charges:

```bash
terraform destroy
```

This will remove all created resources including EC2 instances, S3 buckets, and GuardDuty detector.
