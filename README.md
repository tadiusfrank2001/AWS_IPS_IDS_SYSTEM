# 🛡️ My AWS EC2 Compromise Detection Lab (Terraform Edition)

This is a personal project where I simulate an EC2 compromise scenario using AWS services, and automate the detection and remediation process using **Terraform**.

I built and destroyed a complete security automation pipeline entirely with code — and it's Free Tier friendly as long as I clean everything up afterward.

----

## 🚀 What This Project Does

- Creates two EC2 instances:
  - `EC2-Compromised` (Amazon Linux 2)
  - `EC2-Malicious` (Amazon Linux 2023)
- Assigns a static Elastic IP to the malicious instance
- Hosts a threat list in S3 containing that Elastic IP
- Configures Amazon GuardDuty with the custom threat list
- Simulates malicious behavior from EC2-Compromised
- Triggers GuardDuty findings
- Sends alert notifications via SNS (optional)
- Automatically stops the compromised instance using Lambda triggered by EventBridge

---

## 🧰 AWS Services I Used

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

