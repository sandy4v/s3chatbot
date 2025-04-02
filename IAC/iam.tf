# iam.tf

# IAM role for API Gateway to invoke the Lambda function
resource "aws_iam_role" "api_gateway_bedrock_role" {
  name = "APIGatewayBedrockRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for API Gateway to invoke the Lambda function
resource "aws_iam_policy" "api_gateway_bedrock_policy" {
  name        = "APIGatewayBedrockPolicy"
  description = "Allows API Gateway to invoke Lambda functions" # Updated description

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "lambda:InvokeFunction",
        Effect = "Allow",
        Resource = "*" # Allow invoking any Lambda function
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "api_gateway_bedrock_attachment" {
  role       = aws_iam_role.api_gateway_bedrock_role.name
  policy_arn = aws_iam_policy.api_gateway_bedrock_policy.arn
}

# IAM role for the Bedrock proxy Lambda function
resource "aws_iam_role" "bedrock_proxy_role" {
  name = "BedrockProxyRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for the Bedrock proxy Lambda function to access Bedrock and CloudWatch
resource "aws_iam_policy" "bedrock_proxy_policy" {
  name        = "BedrockProxyPolicy"
  description = "Allows the Bedrock Lambda function to access Bedrock and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "bedrock-runtime:InvokeModel"
        ],
        Effect = "Allow",
        Resource = [
          var.bedrock_completion_model_arn
        ]
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "bedrock_proxy_attachment" {
  role       = aws_iam_role.bedrock_proxy_role.name
  policy_arn = aws_iam_policy.bedrock_proxy_policy.arn
}

# IAM role for the Data Ingestion Lambda function
resource "aws_iam_role" "lambda1_role" {
  name = "DataIngestionLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for the Data Ingestion Lambda function
resource "aws_iam_policy" "data_ingestion_policy" {
  name        = "DataIngestionLambdaPolicy"
  description = "Allows the Data Ingestion Lambda function to access S3, Bedrock, and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::sandeep-patharkar-gen-ai-bckt/*",
          "arn:aws:s3:::sandeep-patharkar-faiss-store-bckt/*"
        ]
      },
      {
        Action = [
          "bedrock-runtime:InvokeModel"
        ],
        Effect = "Allow",
        Resource = [
          var.bedrock_embedding_model_arn
        ]
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda1_attachment" {
  role       = aws_iam_role.lambda1_role.name
  policy_arn = aws_iam_policy.data_ingestion_policy.arn
}