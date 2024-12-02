terraform {
  backend "s3" {
    bucket         = "int-sqs-fv"                # S3 bucket for storing state
    key            = "terraform/state/terraform.tfstate" # Path to state file in S3
    region         = "us-east-1"                # AWS region of the bucket
    encrypt        = true                       # Enable encryption for state file
    dynamodb_table = "terraform-lock-table"     # DynamoDB table for state locking
  }
}

provider "aws" {
  region = var.aws_region
}

# Create SQS Queue
resource "aws_sqs_queue" "task_management_queue" {
  name                      = var.sqs_name
  delay_seconds             = var.sqs_delay_seconds
  max_message_size          = var.sqs_max_message_size
  message_retention_seconds = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
}

# Store SQS URL in AWS Parameter Store
resource "aws_ssm_parameter" "sqs_url_param" {
  name  = var.sqs_url_param_name
  type  = "String"
  value = aws_sqs_queue.task_management_queue.id
}

# Store Kafka Topic Name in Parameter Store
resource "aws_ssm_parameter" "kafka_topic_name_param" {
  name  = var.kafka_topic_param_name
  type  = "String"
  value = var.kafka_topic_name
}

# Outputs
output "sqs_url" {
  description = "The URL of the SQS Queue"
  value       = aws_sqs_queue.task_management_queue.id
}