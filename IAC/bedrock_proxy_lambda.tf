#--------------------------------------------------------------------------------
# Lambda Function 2: Bedrock Proxy Lambda
#--------------------------------------------------------------------------------

resource "aws_lambda_function" "bedrock_proxy_lambda" {
  function_name = "bedrock-proxy-lambda"
  description   = "Proxy to interact with AWS Bedrock"
  handler       = "bedrock_proxy_lambda.lambda_handler"
  runtime       = "python3.11"
  memory_size   = 2048
  timeout       = 300
  role          = aws_iam_role.bedrock_proxy_role.arn

  filename      = "${path.module}/bedrock_proxy_lambda/bedrock_proxy_lambda_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/bedrock_proxy_lambda/bedrock_proxy_lambda_payload.zip")

  environment {
    variables = {
      BEDROCK_MODEL_ID      = var.bedrock_embedding_model_arn
      BEDROCK_RUNTIME_MODEL = "anthropic.claude-v2"
      FAISS_BUCKET          = data.aws_s3_bucket.faiss_bucket.bucket
      FAISS_KEY             = "faiss_index"
      #AWS_REGION            = "us-east-1"
    }
  }

  layers = [
    aws_lambda_layer_version.langchain_layer.arn,
    aws_lambda_layer_version.faiss_layer.arn,
    aws_lambda_layer_version.boto3_layer.arn,
    aws_lambda_layer_version.pdf_layer.arn,
  ]

  depends_on = [
    aws_lambda_layer_version.langchain_layer,
    aws_lambda_layer_version.faiss_layer,
    aws_lambda_layer_version.boto3_layer,
    aws_lambda_layer_version.pdf_layer,
    aws_iam_role_policy_attachment.bedrock_proxy_attachment,
    aws_iam_policy.bedrock_proxy_policy,
    data.aws_s3_bucket.faiss_bucket,
    aws_iam_role.api_gateway_bedrock_role,
    aws_iam_policy.api_gateway_bedrock_policy,
  ]
}

# Allow necessary permissions for Lambda (if needed)
resource "aws_lambda_permission" "allow_api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bedrock_proxy_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  depends_on = [
    aws_lambda_function.bedrock_proxy_lambda,
    aws_apigatewayv2_integration.bedrock_integration, # Added dependency to potentially fix cycle
  ]
}