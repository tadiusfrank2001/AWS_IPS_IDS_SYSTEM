
# Amazon SDK for Python Development, we need to access AWS services so lambda can stop compromised instances
import boto3
import json
import os

def lambda_handler(event, context):
    """
    AWS Lambda function to automatically stop EC2 instances flagged by GuardDuty
    and send notifications via SNS.

    Args:
        event(dict): dictionary containing all the data about what triggered your Lambda usually a JSON format
        context(Object): An object containing metadata about the Lambda execution environment

    Return:
        Status(dict): A dictionary containing status code of instance with instance ID and message about it's successful or unsuccessful termination
    """
    print("Received GuardDuty event:", json.dumps(event, indent=2))
    
    try:
        # Extract instance ID from GuardDuty finding
        instance_id = event['detail']['resource']['instanceDetails']['instanceId']
        print(f"Found compromised instance: {instance_id}")
        
        # Stop the compromised instance
        ec2 = boto3.client('ec2')
        response = ec2.stop_instances(InstanceIds=[instance_id])
        print(f"Stop instance response: {response}")
        
        # Get SNS topic ARN from environment variable
        sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
        if not sns_topic_arn:
            raise ValueError("SNS_TOPIC_ARN environment variable not set")
        
        # Send notification via SNS
        sns = boto3.client('sns')
        message = f"""
GuardDuty Security Alert - Automated Response Triggered

Compromised Instance: {instance_id}
Action Taken: Instance automatically stopped
Finding Type: {event['detail']['type']}
Severity: {event['detail']['severity']}
Time: {event['detail']['updatedAt']}

This is an automated security response from your GuardDuty lab.
"""
        
        sns.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject='🚨 GuardDuty Alert: Instance Auto-Stopped'
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Successfully stopped compromised instance {instance_id}',
                'instanceId': instance_id
            })
        }
        
    except Exception as e:
        print(f"Error processing GuardDuty event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }