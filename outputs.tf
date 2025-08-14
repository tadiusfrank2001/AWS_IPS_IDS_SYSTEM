
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
