#--------------------------------------------------------------------------------
# Data Sources (S3 Buckets)
#--------------------------------------------------------------------------------

data "aws_s3_bucket" "source_bucket" {
  bucket = "sandeep-patharkar-gen-ai-bckt"
}

data "aws_s3_bucket" "faiss_bucket" {
  bucket = "sandeep-patharkar-faiss-store-bckt"
}

#--------------------------------------------------------------------------------
# Lambda Function 1: Data Ingestion and FAISS Index Creation
#--------------------------------------------------------------------------------

# Create the ZIP archive for the Lambda function
data "archive_file" "data_ingestion_lambda_zip" {
  type        = "zip"
  output_path = "data_ingestion_lambda_payload.zip"  # The name of the ZIP file
  source_dir  = "data_ingestion_lambda/package" # Point directly to the package directory
}

resource "aws_lambda_function" "data_ingestion_lambda" {
  function_name = "data-ingestion-lambda"
  description   = "Ingests data from S3, creates embeddings, and builds FAISS index"
  handler       = "package.lambda_function.lambda_handler" # Updated handler
  runtime       = "python3.11"
  memory_size   = 2048
  timeout       = 300
  role          = aws_iam_role.lambda1_role.arn  # Using the newly created IAM role

  # Use the ZIP archive created by the archive_file data source
  filename      = data.archive_file.data_ingestion_lambda_zip.output_path
  source_code_hash = data.archive_file.data_ingestion_lambda_zip.output_base64sha256

  environment {
    variables = {
      SOURCE_BUCKET   = "sandeep-patharkar-gen-ai-bckt"
      FAISS_BUCKET    = "sandeep-patharkar-faiss-store-bckt"
      BEDROCK_MODEL_ID = var.bedrock_embedding_model_arn # Using the variable for Bedrock model ID
      # AWS_REGION       = var.aws_region # Removed as AWS Lambda provides this
    }
  }

  depends_on = [data.archive_file.data_ingestion_lambda_zip]
}

# S3 Bucket Trigger for Lambda 1
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = data.aws_s3_bucket.source_bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_ingestion_lambda.arn
    events       = ["s3:ObjectCreated:*"]
    filter_suffix = ".pdf" # Assuming you want to trigger only on PDF files
  }

  depends_on = [aws_lambda_function.data_ingestion_lambda] # Uncommenting as suggested earlier
}

# Allow S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_ingestion_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.source_bucket.arn
  depends_on = [aws_lambda_function.data_ingestion_lambda] # Added explicit dependency
}