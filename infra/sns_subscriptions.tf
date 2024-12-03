resource "aws_sns_topic_subscription" "marketing_subscription" {
  topic_arn = aws_sns_topic.new_product_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.marketing_queue.arn

  # 
  depends_on = [aws_sqs_queue_policy.marketing_queue_policy]
}

resource "aws_sns_topic_subscription" "inventory_subscription" {
  topic_arn = aws_sns_topic.new_product_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.inventory_queue.arn

  depends_on = [aws_sqs_queue_policy.inventory_queue_policy]
}

resource "aws_sns_topic_subscription" "analytics_subscription" {
  topic_arn = aws_sns_topic.new_product_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.analytics_queue.arn

  depends_on = [aws_sqs_queue_policy.analytics_queue_policy]
}
