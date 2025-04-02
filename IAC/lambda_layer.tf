# lambda_layer.tf
# Create multiple Lambda Layers

# Reference the pre-built Langchain Layer ZIP
resource "aws_lambda_layer_version" "langchain_layer" {
  layer_name          = "gen-ai-langchain-dependencies"
  filename            = "${path.module}/shared_dependencies/langchain_layer_payload.zip"
  compatible_runtimes = ["python3.11"]
}

# Reference the pre-built FAISS Layer ZIP
resource "aws_lambda_layer_version" "faiss_layer" {
  layer_name          = "gen-ai-faiss-dependencies"
  filename            = "${path.module}/shared_dependencies/faiss_layer_payload.zip"
  compatible_runtimes = ["python3.11"]
}

# Reference the pre-built Boto3 Layer ZIP
resource "aws_lambda_layer_version" "boto3_layer" {
  layer_name          = "gen-ai-boto3-dependencies"
  filename            = "${path.module}/shared_dependencies/boto3_layer_payload.zip"
  compatible_runtimes = ["python3.11"]
}

# Reference the pre-built PDF Processing Layer ZIP
resource "aws_lambda_layer_version" "pdf_layer" {
  layer_name          = "gen-ai-pdf-dependencies"
  filename            = "${path.module}/shared_dependencies/pdf_layer_payload.zip"
  compatible_runtimes = ["python3.11"]
}
