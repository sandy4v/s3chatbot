variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region to deploy resources to."
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}

variable "api_gateway_name" {
  type        = string
  default     = "S3APIGateway"
  description = "The name of the API Gateway."
}

variable "api_gateway_stage_name" {
  type        = string
  default     = "dev"
  description = "The name of the API Gateway stage."
}