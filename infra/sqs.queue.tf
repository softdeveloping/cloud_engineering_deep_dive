resource "aws_sqs_queue" "marketing_queue" {
  name = "MarketingQueue"

  tags = {
    Environment = terraform.workspace
    Project     = local.project_name
  }
}

resource "aws_sqs_queue" "inventory_queue" {
  name = "InventoryQueue"

  tags = {
    Environment = terraform.workspace
    Project     = local.project_name
  }
}

resource "aws_sqs_queue" "analytics_queue" {
  name = "AnalyticsQueue"

  tags = {
    Environment = terraform.workspace
    Project     = local.project_name
  }
}

# Outputs for queue ARNs and URLs
output "marketing_queue_arn" {
  description = "ARN of the MarketingQueue"
  value       = aws_sqs_queue.marketing_queue.arn
}

output "inventory_queue_arn" {
  description = "ARN of the InventoryQueue"
  value       = aws_sqs_queue.inventory_queue.arn
}

output "analytics_queue_arn" {
  description = "ARN of the AnalyticsQueue"
  value       = aws_sqs_queue.analytics_queue.arn
}
