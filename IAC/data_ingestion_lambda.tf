# data_ingestion_lambda.tf
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


resource "aws_lambda_function" "data_ingestion_lambda" {
  function_name = "data-ingestion-lambda"
  description   = "Ingests data from S3, creates embeddings, and builds FAISS index."
  handler       = "data_ingestion_lambda.lambda_handler"
  runtime       = "python3.11"
  memory_size   = 2048
  timeout       = 300
  role          = aws_iam_role.lambda1_role.arn

  filename      = "${path.module}/data_ingestion_lambda/data_ingestion_lambda_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/data_ingestion_lambda/data_ingestion_lambda_payload.zip")

  environment {
    variables = {
      SOURCE_BUCKET   = "sandeep-patharkar-gen-ai-bckt"
      FAISS_BUCKET    = "sandeep-patharkar-faiss-store-bckt"
      BEDROCK_MODEL_ID = var.bedrock_embedding_model_arn
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
    aws_iam_role_policy_attachment.lambda1_attachment,
    aws_iam_policy.data_ingestion_policy,
    data.aws_s3_bucket.source_bucket,
    data.aws_s3_bucket.faiss_bucket,
  ]
}

# S3 Bucket Trigger for Lambda 1
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = data.aws_s3_bucket.source_bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_ingestion_lambda.arn
    events       = ["s3:ObjectCreated:*"]
    filter_suffix = ".pdf"
  }

  depends_on = [aws_lambda_function.data_ingestion_lambda]
}

# Allow S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_ingestion_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.source_bucket.arn
  depends_on = [aws_lambda_function.data_ingestion_lambda]
}