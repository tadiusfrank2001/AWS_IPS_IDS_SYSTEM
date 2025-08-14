
# ===== EC2 INSTANCE OUTPUTS =====

output "compromised_instance_id" {
  description = "Instance ID of the compromised EC2 instance"
  value       = aws_instance.ec2_compromised.id
}

output "compromised_instance_public_ip" {
  description = "Public IP address of the compromised instance"
  value       = aws_instance.ec2_compromised.public_ip
}

output "compromised_instance_private_ip" {
  description = "Private IP address of the compromised instance"
  value       = aws_instance.ec2_compromised.private_ip
}

output "malicious_instance_id" {
  description = "Instance ID of the malicious EC2 instance"
  value       = aws_instance.ec2_malicious.id
}

output "malicious_instance_public_ip" {
  description = "Public IP address of the malicious instance (Elastic IP)"
  value       = aws_eip.malicious_ip.public_ip
}

output "malicious_instance_private_ip" {
  description = "Private IP address of the malicious instance"
  value       = aws_instance.ec2_malicious.private_ip
}






# ===== SSH CONNECTION COMMANDS =====

output "ssh_command_compromised" {
  description = "SSH command to connect to the compromised instance"
  value       = "ssh -i ~/.ssh/guardduty_lab_key ec2-user@${aws_instance.ec2_compromised.public_ip}"
}

output "ssh_command_malicious" {
  description = "SSH command to connect to the malicious instance"
  value       = "ssh -i ~/.ssh/guardduty_lab_key ec2-user@${aws_eip.malicious_ip.public_ip}"
}






# ===== S3 BUCKET OUTPUTS =====

output "guardduty_bucket_name" {
  description = "Name of the GuardDuty lab S3 bucket"
  value       = aws_s3_bucket.gd_lab_bucket.bucket
}

output "threat_list_bucket_name" {
  description = "Name of the threat intelligence S3 bucket"
  value       = aws_s3_bucket.gd_threat_list.bucket
}

output "threat_list_url" {
  description = "S3 URL of the threat intelligence list"
  value       = "https://${aws_s3_bucket.gd_threat_list.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/threatlist.txt"
}




# ===== GUARDDUTY OUTPUTS =====

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.gd_lab_detector.id
}

output "guardduty_console_url" {
  description = "Direct URL to GuardDuty console for this region"
  value       = "https://console.aws.amazon.com/guardduty/home?region=${data.aws_region.current.name}#/findings"
}









# ===== SECURITY HUB OUTPUTS =====

output "security_hub_console_url" {
  description = "Direct URL to Security Hub console"
  value       = "https://console.aws.amazon.com/securityhub/home?region=${data.aws_region.current.name}#/findings"
}





# ===== SNS OUTPUTS =====

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.gd_lab_alerts.arn
}

output "alert_email" {
  description = "Email address configured for alerts (you must confirm subscription)"
  value       = var.alert_email
  sensitive   = true
}




 # ===== LAMBDA OUTPUTS =====

output "lambda_function_name" {
  description = "Name of the Lambda function for automated response"
  value       = aws_lambda_function.gd_stop_compromised_instance.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.gd_stop_compromised_instance.arn
}


# ===== ACCOUNT INFO =====

output "aws_account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Current AWS region"
  value       = data.aws_region.current.name
}

output "random_suffix" {
  description = "Random suffix used for unique naming"
  value       = random_id.lab_suffix.hex
}




# ===== NETWORK OUTPUTS =====

output "vpc_id" {
  description = "ID of the VPC being used"
  value       = data.aws_vpc.default.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.gd_lab_sg.id
}

output "key_pair_name" {
  description = "Name of the SSH key pair created"
  value       = aws_key_pair.gd_lab_keypair.key_name
}




# ===== LAB INSTRUCTIONS =====

output "lab_instructions" {
  description = "Next steps for running the GuardDuty lab"
  value = <<EOF

🚀 GUARDDUTY LAB SETUP COMPLETE! 

📋 NEXT STEPS:
1. Confirm your SNS email subscription (check your email: ${var.alert_email})
2. Wait 5-10 minutes for GuardDuty to fully initialize
3. SSH into compromised instance: ssh -i ~/.ssh/guardduty_lab_key ec2-user@${aws_instance.ec2_compromised.public_ip}
4. Generate malicious traffic: curl http://${aws_eip.malicious_ip.public_ip}
5. Check GuardDuty console: ${data.aws_region.current.name}
6. Monitor for automatic instance shutdown and email alerts

🔗 USEFUL URLS:
- GuardDuty Console: https://console.aws.amazon.com/guardduty/home?region=${data.aws_region.current.name}#/findings
- Security Hub: https://console.aws.amazon.com/securityhub/home?region=${data.aws_region.current.name}#/findings
- Lambda Logs: https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:log-groups

⚠️  REMEMBER: This is a lab environment. Clean up with 'terraform destroy' when done!

EOF
}

# ===== COST ESTIMATION =====

output "estimated_hourly_cost" {
  description = "Estimated hourly cost for running this lab (approximate)"
  value = <<EOF
Estimated costs per hour (us-east-1):
- 2x EC2 instances (t2.micro + t3.micro): ~$0.02/hour
- GuardDuty: ~$0.0042/hour 
- Security Hub: ~$0.0033/hour
- S3, Lambda, SNS: <$0.01/hour
TOTAL: ~$0.03-0.04/hour

Note: Costs may vary by region and usage. Always check current AWS pricing.
EOF
}