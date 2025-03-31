import json
import boto3
import os

from langchain_community.embeddings import BedrockEmbeddings
from langchain_community.vectorstores import FAISS

# S3 Configuration
faiss_bucket = os.environ.get("FAISS_BUCKET", "sandeep-patharkar-faiss-store-bckt")  # FAISS Bucket
faiss_key = "faiss_index"  # Key (prefix) for FAISS index in S3

# Bedrock Configuration
bedrock_model_id = os.environ.get("BEDROCK_MODEL_ID", "amazon.titan-embed-text-v1")
bedrock_region = os.environ.get("AWS_REGION", "us-east-1")
bedrock_runtime_model = os.environ.get("BEDROCK_RUNTIME_MODEL", "anthropic.claude-v2")

# Local directory for FAISS index
persist_directory = "/tmp/faiss_index"

def load_vector_store_from_s3(s3_client, bucket, key, persist_directory):
    """Loads a FAISS vector store from S3."""
    try:
        # Ensure /tmp exists
        if not os.path.exists(persist_directory):
            os.makedirs(persist_directory)

        local_path = os.path.join(persist_directory, "index.faiss")
        s3_client.download_file(bucket, f"{key}/index.faiss", local_path)
        local_path = os.path.join(persist_directory, "index.pkl")
        s3_client.download_file(bucket, f"{key}/index.pkl", local_path)

        vectordb = FAISS.load_local(persist_directory, create_bedrock_embeddings())
        print("Loaded vectorstore from S3")
        return vectordb
    except Exception as e:
        print(f"Error loading vector store from S3: {e}")
        return None

def create_bedrock_embeddings():
    """Creates Bedrock embeddings."""
    return BedrockEmbeddings(
        model_id=bedrock_model_id,
        region_name=bedrock_region
    )

def process_query(query, vectordb):
    """Processes a user query using the vector store and Bedrock."""
    try:
        # Embed the query
        embedding_vector = create_bedrock_embeddings().embed_query(query)

        # Search the vector store for relevant chunks
        docs = vectordb.similarity_search_by_vector(embedding_vector, k=4)  # Adjust k as needed

        # Format the context for Bedrock
        context = "\n".join([doc.page_content for doc in docs])

        # Construct the Bedrock prompt
        prompt = f"""Human: Answer the question based on the context below.
        Context: {context}

        Question: {query}

        Assistant:"""

        # Invoke Bedrock
        bedrock_runtime = boto3.client(
            service_name='bedrock-runtime',
            region_name=bedrock_region
        )

        response = bedrock_runtime.invoke_model(
            body=json.dumps({
                "prompt": prompt,
                "max_tokens_to_sample": 300,  # Adjust as needed
                "temperature": 0.5,
                "top_p": 0.9
            }),
            modelId=bedrock_runtime_model,
            accept="application/json",
            contentType="application/json"
        )

        response_body = json.loads(response['body'].read().decode('utf-8'))
        answer = response_body['completion']  # Adjust based on the model

        return answer

    except Exception as e:
        print(f"Error processing query: {e}")
        return f"Error: {e}"

def lambda_handler(event, context):
    """Main Lambda function handler."""
    print("Received event:", json.dumps(event))

    try:
        # 1. Initialize S3 client
        s3 = boto3.client('s3')

        # 2. Get the query from the event
        query = event["queryStringParameters"]["query"]

        # 3. Load the vector store from S3
        vectordb = load_vector_store_from_s3(s3, faiss_bucket, faiss_key, persist_directory)
        if not vectordb:
            return {
                'statusCode': 500,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps("Error: Could not load FAISS index from S3.")
            }

        # 4. Process the query
        answer = process_query(query, vectordb)

        # 5. Return the response
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({"answer": answer})
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(f"Error: {str(e)}")
        }