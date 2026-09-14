terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Input bucket - where uploaded files land
resource "aws_s3_bucket" "input" {
  bucket = "andrewmccollin-pipeline-input"
}

# Output bucket - where processed results are stored
resource "aws_s3_bucket" "output" {
  bucket = "andrewmccollin-pipeline-output"
}
# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "serverless-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# Allow public access on output bucket
resource "aws_s3_bucket_public_access_block" "output" {
  bucket = aws_s3_bucket.output.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public read policy for output bucket
resource "aws_s3_bucket_policy" "output" {
  bucket = aws_s3_bucket.output.id

  depends_on = [aws_s3_bucket_public_access_block.output]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.output.arn}/*"
      }
    ]
  })
}

# CORS configuration for input bucket
resource "aws_s3_bucket_cors_configuration" "input" {
  bucket = aws_s3_bucket.input.id

  cors_rule {

    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["https://andrewmccollin.tech"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}

# CORS configuration for output bucket
resource "aws_s3_bucket_cors_configuration" "output" {
  bucket = aws_s3_bucket.output.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://andrewmccollin.tech"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}
# Zip the Lambda function code
data "archive_file" "presign" {
  type        = "zip"
  source_file = "${path.module}/presign.py"
  output_path = "${path.module}/presign.zip"
}

data "archive_file" "processor" {
  type        = "zip"
  source_file = "${path.module}/processor.py"
  output_path = "${path.module}/processor.zip"
}
# Presign Lambda function
resource "aws_lambda_function" "presign" {
  filename         = data.archive_file.presign.output_path
  function_name    = "serverless-presign"
  role             = aws_iam_role.lambda_role.arn
  handler          = "presign.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.presign.output_base64sha256

  environment {
    variables = {
      INPUT_BUCKET = aws_s3_bucket.input.bucket
    }
  }
}

# Processor Lambda function
resource "aws_lambda_function" "processor" {
  filename         = data.archive_file.processor.output_path
  function_name    = "serverless-processor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "processor.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.processor.output_base64sha256

  environment {
    variables = { 
      OUTPUT_BUCKET = aws_s3_bucket.output.bucket
    }
  }
}
# Lambda Function URL for presign function
resource "aws_lambda_function_url" "presign" {
  function_name      = aws_lambda_function.presign.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["https://andrewmccollin.tech"]
    allow_methods     = ["GET"]
    allow_headers     = ["content-type"]
    max_age           = 86400
  }
}
# Allow public invocation of presign Lambda (required since Oct 2025)
resource "aws_lambda_permission" "presign_public_invoke" {
  statement_id  = "FunctionURLInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presign.function_name
  principal     = "*"
}
output "presign_function_url" {
  value = aws_lambda_function_url.presign.function_url
}
# Allow S3 to invoke the processor Lambda
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input.arn
}

# S3 event notification to trigger processor Lambda
resource "aws_s3_bucket_notification" "input" {
  bucket = aws_s3_bucket.input.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}