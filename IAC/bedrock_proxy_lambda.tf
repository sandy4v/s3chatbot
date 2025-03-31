#--------------------------------------------------------------------------------
# Lambda Function 2: Bedrock Proxy Lambda
#--------------------------------------------------------------------------------

# Create the ZIP archive for the Lambda function
data "archive_file" "bedrock_proxy_lambda_zip" {
  type        = "zip"
  output_path = "bedrock_proxy_lambda_payload.zip"  # The name of the ZIP file
  source_dir  = "${path.module}/bedrock_proxy_lambda" # Using the Lambda source directory directly
}

resource "aws_lambda_function" "bedrock_proxy_lambda" {
  function_name = "bedrock-proxy-lambda"
  description   = "Proxy to interact with AWS Bedrock"
  handler       = "bedrock_proxy_lambda.lambda_function.lambda_handler" # Updated handler
  runtime       = "python3.11"
  memory_size   = 2048
  timeout       = 300
  role          = aws_iam_role.lambda2_role.arn  # Using the newly created IAM role

  # Use the ZIP archive created by the archive_file data source
  filename      = data.archive_file.bedrock_proxy_lambda_zip.output_path
  source_code_hash = data.archive_file.bedrock_proxy_lambda_zip.output_base64sha256

  environment {
    variables = {
      BEDROCK_MODEL_ID = var.bedrock_embedding_model_arn # Using the variable for Bedrock model ID
      # Add other environment variables here as needed
    }
  }

  layers = [
    aws_lambda_layer_version.lambda_layer.arn  # Referencing the shared dependencies layer
  ]

  depends_on = [data.archive_file.bedrock_proxy_lambda_zip, aws_lambda_layer_version.lambda_layer]
}

# Allow necessary permissions for Lambda (if needed)
resource "aws_lambda_permission" "allow_api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bedrock_proxy_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  depends_on = [aws_lambda_function.bedrock_proxy_lambda] # Added explicit dependency
}