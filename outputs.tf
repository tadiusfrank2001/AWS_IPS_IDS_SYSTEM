
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
