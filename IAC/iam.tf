# IAM Role for API Gateway to Access S3
resource "aws_iam_role" "api_gateway_s3_role" {
  name = "api-gateway-s3-role"

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

# IAM Policy to Allow Access to the S3 Bucket
resource "aws_iam_policy" "api_gateway_s3_policy" {
  name        = "api-gateway-s3-policy"
  description = "Policy to allow API Gateway to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ],
        Effect = "Allow",
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      }
    ]
  })
}

# Attach the Policy to the Role
resource "aws_iam_role_policy_attachment" "api_gateway_s3_policy_attachment" {
  role       = aws_iam_role.api_gateway_s3_role.name
  policy_arn = aws_iam_policy.api_gateway_s3_policy.arn
}