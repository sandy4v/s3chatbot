# lambda_function.py

import json
import boto3
import os
import tempfile

from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.embeddings import BedrockEmbeddings
from langchain_community.vectorstores import FAISS

# S3 Configuration
source_bucket = os.environ.get("SOURCE_BUCKET", "sandeep-patharkar-gen-ai-bckt")  # Trigger Bucket
faiss_bucket = os.environ.get("FAISS_BUCKET", "sandeep-patharkar-faiss-store-bckt")  # FAISS Bucket
faiss_key = "faiss_index"  # Key (prefix) for FAISS index in S3

# Bedrock Configuration
bedrock_model_id = os.environ.get("BEDROCK_MODEL_ID", "amazon.titan-embed-text-v1")
bedrock_region = os.environ.get("AWS_REGION", "us-east-1")

# Local directory for FAISS index
persist_directory = "/tmp/faiss_index"

def load_pdf_from_s3(bucket, key, s3_client):
    """Loads a single PDF document from S3 using PyPDFLoader."""
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as temp_file:
            s3_client.download_fileobj(bucket, key, temp_file)
            temp_file_path = temp_file.name
            loader = PyPDFLoader(temp_file_path)
            documents = loader.load()
            os.remove(temp_file_path)
            return documents
    except Exception as e:
        print(f"Error loading PDF {key}: {e}")
        return None

def create_chunks(documents, chunk_size=1000, chunk_overlap=100):
    """Splits the documents into smaller chunks."""
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size, chunk_overlap=chunk_overlap
    )
    chunks = text_splitter.split_documents(documents)
    return chunks

def create_bedrock_embeddings():
    """Creates Bedrock embeddings."""
    return BedrockEmbeddings(
        model_id=bedrock_model_id,
        region_name=bedrock_region
    )

def create_vector_store(chunks, embeddings, persist_directory):
    """Creates a FAISS vector store."""
    vectordb = FAISS.from_documents(chunks, embeddings)
    vectordb.save_local(persist_directory)
    return vectordb

def save_vector_store_to_s3(s3_client, bucket, key, persist_directory):
    """Saves the FAISS vector store to S3."""
    try:
        local_path = os.path.join(persist_directory, "index.faiss")
        s3_client.upload_file(local_path, bucket, f"{key}/index.faiss")
        local_path = os.path.join(persist_directory, "index.pkl")
        s3_client.upload_file(local_path, bucket, f"{key}/index.pkl")
        print("Saved vectorstore to S3")
    except Exception as e:
        print(f"Error saving vector store to S3: {e}")

def lambda_handler(event, context):
    """Main Lambda function handler."""
    print("Received event:", json.dumps(event))

    try:
        # 0. Ensure /tmp exists
        if not os.path.exists("/tmp"):
            os.makedirs("/tmp")

        # 1. Initialize S3 client
        s3 = boto3.client('s3')

        # 2. Get the S3 object key from the event
        key = event['Records'][0]['s3']['object']['key']
        print(f"Detected S3 upload for file: {key}")

        # 3. Load the PDF from S3
        documents = load_pdf_from_s3(source_bucket, key, s3)
        if not documents:
            return {
                'statusCode': 500,
                'body': json.dumps(f"Error: Could not load PDF from S3: {key}")
            }

        # 4. Create Chunks
        chunks = create_chunks(documents)
        print(f"Created {len(chunks)} chunks")

        # 5. Create Bedrock Embeddings
        print("Creating Bedrock embeddings...")
        bedrock_embeddings = create_bedrock_embeddings()
        print("Bedrock embeddings created.")

        # 6. Create Vectorstore
        print(f"Creating FAISS vector store in {persist_directory}...")
        vectordb = create_vector_store(chunks, bedrock_embeddings, persist_directory)
        print(f"FAISS vector store created and persisted to {persist_directory}")

        # 7. Save the vector store to S3
        save_vector_store_to_s3(s3, faiss_bucket, faiss_key, persist_directory)

        return {
            'statusCode': 200,
            'body': json.dumps(f"Successfully created/updated FAISS vector store with {len(chunks)} chunks.")
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }