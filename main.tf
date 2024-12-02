terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=5.42"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0.5"
    }
  }

  backend "s3" {
    bucket         = "int-sqs-fv"                  # Replace with your S3 bucket for state
    key            = "terraform/state/terraform.tfstate"
    region         = "us-east-1"                  # AWS region of the bucket
    encrypt        = true                         # Enable encryption for state file
    dynamodb_table = "terraform-lock-table"       # DynamoDB table for state locking
  }
}

provider "aws" {
  region = var.aws_region

  # Ignore specific tags to avoid unnecessary state changes
  ignore_tags {
    key_prefixes = ["Environment", "Owner"]
  }
}

# Create Dead-Letter Queue (DLQ)
resource "aws_sqs_queue" "task_management_dlq" {
  name = "${var.environment_tag}-${var.aws_region}-wf-taskmanagement-dlq"

  tags = {
    Environment = var.environment_tag
    Owner       = "workflow-team"
  }
}

# Create Main SQS Queue with DLQ
resource "aws_sqs_queue" "task_management_queue" {
  name                      = "${var.environment_tag}-${var.aws_region}-wf-taskmanagement-queue"
  delay_seconds             = var.sqs_delay_seconds
  max_message_size          = var.sqs_max_message_size
  message_retention_seconds = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.task_management_dlq.arn
    maxReceiveCount     = 5 # Messages will be moved to DLQ after 5 retries
  })

  tags = {
    Environment = var.environment_tag
    Owner       = "workflow-team"
  }
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

# Create CloudWatch Alarm for ApproximateNumberOfMessagesVisible
resource "aws_cloudwatch_metric_alarm" "sqs_visible_messages" {
  alarm_name          = "${var.environment_tag}_${var.aws_region}_sqs_message_count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = 100 # Threshold for visible messages
  actions_enabled     = true
  alarm_description   = "Alert when the SQS queue has too many visible messages."

  dimensions = {
    QueueName = aws_sqs_queue.task_management_queue.name
  }
}

# Outputs
output "sqs_url" {
  description = "The URL of the SQS Queue"
  value       = aws_sqs_queue.task_management_queue.id
}

output "dlq_url" {
  description = "The URL of the Dead-Letter Queue"
  value       = aws_sqs_queue.task_management_dlq.id
}