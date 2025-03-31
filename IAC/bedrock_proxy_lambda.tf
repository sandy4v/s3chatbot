# bedrock-proxy-lambda.tf

# Create the ZIP archive for the Lambda function
data "archive_file" "lambda_function_zip" {
  type        = "zip"
  output_path = "lambda_function_payload.zip"  # The name of the ZIP file
  source_dir  = "./bedrock_proxy_lambda/package" # Point directly to the package directory
}

# Create the Lambda function
resource "aws_lambda_function" "bedrock_proxy" {
  function_name = "BedrockProxy"
  description   = "Proxies requests to Amazon Bedrock"
  handler       = "package.lambda_function.lambda_handler"  # Updated handler
  runtime       = "python3.9"  # Or your preferred Python runtime
  timeout       = 30          # Timeout in seconds (adjust as needed)
  memory_size   = 128         # Memory allocation in MB (adjust as needed)
  role          = aws_iam_role.bedrock_proxy_role.arn  # IAM role for the Lambda function
  # The path to the ZIP archive containing your Lambda function code
  filename      = data.archive_file.lambda_function_zip.output_path
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256

  environment {
    variables = {
      #AWS_REGION = var.aws_region # Using the variable for AWS region
    }
  }

  depends_on = [data.archive_file.lambda_function_zip]
}