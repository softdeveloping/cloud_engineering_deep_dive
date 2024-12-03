resource "aws_sns_topic" "new_product_topic" {
  name = "NewProductTopic"
  tags = {
    Environment = terraform.workspace
    Project     = local.project_name
  }
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.new_product_topic.arn
}