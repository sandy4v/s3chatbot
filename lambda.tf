# lambda.tf

# 1. IAM Role for Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "lambda-s3-reader-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid = ""
      }
    ]
  })
}

# 2. IAM Policy for Lambda Function
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-s3-reader-policy"
  description = "IAM policy for Lambda to read from S3 and write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ],
        Effect = "Allow",
        Resource = "arn:aws:s3:::s3chatbot.com/*" # Replace with your actual bucket ARN
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

# 3. Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}