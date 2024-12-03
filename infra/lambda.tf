data "archive_file" "marketing_processor_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambdas/marketing_processor/src"
  output_path = "${path.module}/../src/lambdas/marketing_processor/dist/function.zip"
}

data "archive_file" "inventory_processor_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambdas/inventory_processor/src"
  output_path = "${path.module}/../src/lambdas/inventory_processor/dist/function.zip"
}

data "archive_file" "analytics_processor_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambdas/analytics_processor/src"
  output_path = "${path.module}/../src/lambdas/analytics_processor/dist/function.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${terraform.workspace}_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Environment = terraform.workspace
    Project     = local.project_name
  }
}

# 
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# policy access for SQS
resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# MarketingProcessor Lambda Function
resource "aws_lambda_function" "marketing_processor" {
  function_name = "MarketingProcessor"
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.marketing_processor_zip.output_path
  source_code_hash = data.archive_file.marketing_processor_zip.output_base64sha256

  tags = {
    Environment = terraform.workspace
    Project     = local.project_name
  }
}

# InventoryProcessor Lambda Function
resource "aws_lambda_function" "inventory_processor" {
  function_name = "InventoryProcessor"
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.inventory_processor_zip.output_path
  source_code_hash = data.archive_file.inventory_processor_zip.output_base64sha256

  tags = {
    Environment = terraform.workspace
    Project     = local.project_name
  }
}

# AnalyticsProcessor Lambda Function
resource "aws_lambda_function" "analytics_processor" {
  function_name = "AnalyticsProcessor"
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.analytics_processor_zip.output_path
  source_code_hash = data.archive_file.analytics_processor_zip.output_base64sha256

  tags = {
    Environment = terraform.workspace
    Project     = local.project_name
  }
}

# Event source mapping for MarketingProcessor
resource "aws_lambda_event_source_mapping" "marketing_event_source" {
  event_source_arn = aws_sqs_queue.marketing_queue.arn
  function_name    = aws_lambda_function.marketing_processor.arn
  batch_size       = 10
  enabled          = true
}

# Event source mapping for InventoryProcessor
resource "aws_lambda_event_source_mapping" "inventory_event_source" {
  event_source_arn = aws_sqs_queue.inventory_queue.arn
  function_name    = aws_lambda_function.inventory_processor.arn
  batch_size       = 10
  enabled          = true
}

# Event source mapping for AnalyticsProcessor
resource "aws_lambda_event_source_mapping" "analytics_event_source" {
  event_source_arn = aws_sqs_queue.analytics_queue.arn
  function_name    = aws_lambda_function.analytics_processor.arn
  batch_size       = 10
  enabled          = true
}
