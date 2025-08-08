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

