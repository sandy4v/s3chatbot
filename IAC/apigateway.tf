# apigateway.tf

# Defines the HTTP API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"
  # target        = aws_lambda_function.bedrock_proxy.invoke_arn # Removed this line
  route_selection_expression = "$request.method $request.path"
}

# Route for POST requests to /chat
resource "aws_apigatewayv2_route" "chat_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /chat"  # Route for POST requests to /chat
  target    = "integrations/${aws_apigatewayv2_integration.bedrock_integration.id}"
}

# Defines how the API Gateway integrates with the Lambda function
resource "aws_apigatewayv2_integration" "bedrock_integration" { # Changed to bedrock_integration
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.bedrock_proxy.invoke_arn # Ensure this matches your Lambda resource name
  payload_format_version = "2.0"
  credentials_arn = aws_iam_role.api_gateway_bedrock_role.arn # Ensure this matches your IAM role resource name
}

# Defines the default stage for the API Gateway
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id     = aws_apigatewayv2_api.http_api.id
  name       = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format          = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      httpMethod              = "$context.httpMethod"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      integrationErrorMessage = "$context.integrationErrorMessage"
      errorMessage            = "$context.error.message"
      extendedRequestId       = "$context.extendedRequestId"
      responseLength          = "$context.responseLength"
    })
  }
}

# Defines a CloudWatch Log Group where API Gateway logs will be stored
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/api_gateway/${aws_apigatewayv2_api.http_api.name}"
  retention_in_days = 7
}