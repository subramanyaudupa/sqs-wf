aws_region = "us-east-1"
environment_tag = "int"

# SQS Configuration
sqs_delay_seconds             = 0
sqs_max_message_size          = 262144
sqs_message_retention_seconds = 345600
sqs_visibility_timeout_seconds = 30

# Parameter Store Configuration
sqs_url_param_name = "TskMgmtParameter_SQSURL"
kafka_topic_param_name = "TskMgmtParameter_DeleteTopicName"
kafka_topic_name       = "task_management_failed_messages"