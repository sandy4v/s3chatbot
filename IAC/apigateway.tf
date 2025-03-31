# Defines the HTTP API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "S3ProxyAPI"  # The name of the API Gateway
  protocol_type = "HTTP"      # Specifies that it's an HTTP API (v2)
  target        = aws_lambda_function.s3_proxy.invoke_arn  # The ARN of the Lambda function that the API Gateway will invoke

  # Required to use the default route.  This tells API Gateway how to choose a route.
  # In this case, it uses the HTTP method (GET, POST, etc.)
  route_selection_expression = "$request.method"
}

# Defines the default route for the API Gateway
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id  # The ID of the API Gateway
  # Matches all GET requests.  The {proxy+} part is a path parameter that captures everything after the first slash.
  route_key = "GET /{proxy+}"

  # Specifies the integration to use for this route.  In this case, it's the S3 integration.
  target = "integrations/${aws_apigatewayv2_integration.s3_integration.id}"
}

# Defines how the API Gateway integrates with the Lambda function
resource "aws_apigatewayv2_integration" "s3_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id  # The ID of the API Gateway
  integration_type   = "AWS_PROXY"  # Means that the API Gateway will proxy the request to the Lambda function
  integration_uri    = aws_lambda_function.s3_proxy.invoke_arn  # The ARN of the Lambda function
  # Required for HTTP API Lambda integration.  Specifies the format of the payload sent to the Lambda function.
  payload_format_version = "2.0"

  # IAM role ARN for API Gateway to invoke Lambda.  This role must have permission to invoke the Lambda function.
  credentials_arn = aws_iam_role.api_gateway_s3_role.arn
}

# Defines the default stage for the API Gateway.  A stage is a snapshot of the API Gateway configuration.
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id     = aws_apigatewayv2_api.http_api.id  # The ID of the API Gateway
  name       = "$default"  # The default stage.  This is a special name that always refers to the latest deployment.
  auto_deploy = true       # True means that changes to the API Gateway will be automatically deployed to this stage.

  # Optional: Access logging settings (configure CloudWatch Logs)
  access_log_settings {
    # The ARN of the CloudWatch Log Group where the API Gateway logs will be stored.
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    # The format of the log messages.  This is a JSON object that specifies which information to include in the logs.
    format          = jsonencode({
      requestId               = "$context.requestId"               # The unique ID of the request
      sourceIp                = "$context.identity.sourceIp"         # The IP address of the client
      requestTime             = "$context.requestTime"            # The time the request was received
      httpMethod              = "$context.httpMethod"               # The HTTP method used (GET, POST, etc.)
      routeKey                = "$context.routeKey"                # The route key that was matched
      status                  = "$context.status"                  # The HTTP status code returned
      integrationErrorMessage = "$context.integrationErrorMessage" # Any error message from the integration
      errorMessage            = "$context.error.message"            # Any error message from the API Gateway
    })
  }
}

# Defines a CloudWatch Log Group where API Gateway logs will be stored
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  # The name of the log group.  This will be in the format /aws/api_gateway/<API Gateway name>
  name              = "/aws/api_gateway/${aws_apigatewayv2_api.http_api.name}"
  retention_in_days = 7  # How long to keep the logs (in days)
}