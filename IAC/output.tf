output "api_gateway_invoke_url" {
  description = "The invoke URL of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_gateway_execution_arn" {
  description = "The ARN of the API Gateway execution role"
  value       = aws_iam_role.api_gateway_s3_role.arn
}