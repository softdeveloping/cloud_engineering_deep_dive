# policy for MarketingQueue
resource "aws_sqs_queue_policy" "marketing_queue_policy" {
  queue_url = aws_sqs_queue.marketing_queue.id
  policy    = data.aws_iam_policy_document.marketing_queue_policy.json
}

data "aws_iam_policy_document" "marketing_queue_policy" {
  statement {
    actions = ["sqs:SendMessage"]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    resources = [aws_sqs_queue.marketing_queue.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.new_product_topic.arn]
    }
  }
}

# policy for InventoryQueue
resource "aws_sqs_queue_policy" "inventory_queue_policy" {
  queue_url = aws_sqs_queue.inventory_queue.id
  policy    = data.aws_iam_policy_document.inventory_queue_policy.json
}

data "aws_iam_policy_document" "inventory_queue_policy" {
  statement {
    actions = ["sqs:SendMessage"]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    resources = [aws_sqs_queue.inventory_queue.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.new_product_topic.arn]
    }
  }
}

# policy for AnalyticsQueue
resource "aws_sqs_queue_policy" "analytics_queue_policy" {
  queue_url = aws_sqs_queue.analytics_queue.id
  policy    = data.aws_iam_policy_document.analytics_queue_policy.json
}

data "aws_iam_policy_document" "analytics_queue_policy" {
  statement {
    actions = ["sqs:SendMessage"]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    resources = [aws_sqs_queue.analytics_queue.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.new_product_topic.arn]
    }
  }
}
