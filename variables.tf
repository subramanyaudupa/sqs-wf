# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

# SQS Queue Variables
variable "sqs_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "sqs_delay_seconds" {
  description = "Delay in seconds for SQS messages"
  type        = number
  default     = 0
}

variable "sqs_max_message_size" {
  description = "Maximum message size for SQS"
  type        = number
  default     = 262144
}

variable "sqs_message_retention_seconds" {
  description = "Message retention time in seconds for SQS"
  type        = number
  default     = 345600
}

variable "sqs_visibility_timeout_seconds" {
  description = "Visibility timeout for SQS in seconds"
  type        = number
  default     = 30
}

# Parameter Store Variable
variable "sqs_url_param_name" {
  description = "Parameter name to store SQS URL in Parameter Store"
  type        = string
}

# Kafka Topic Parameter Store Variables
variable "kafka_topic_param_name" {
  description = "Parameter name to store Kafka topic name in Parameter Store"
  type        = string
}

variable "kafka_topic_name" {
  description = "Name of the Kafka topic for failed messages"
  type        = string
}
