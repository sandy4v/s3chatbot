# s3chatbot
AI chatbot on s3

# Refactoring Streamlit App to AWS with React

This document outlines the steps to refactor a Streamlit Python application to AWS, utilizing React for the front end, S3 hosting, API Gateway, Lambda, and Bedrock.

## 1. Develop the Lambda Function (Backend)

*   **Translate Streamlit Logic:** Convert the core logic from your Streamlit app that interacts with Bedrock into a Python Lambda function. This function should:
    *   Receive the user's query from API Gateway.
    *   Send the query to Amazon Bedrock.
    *   Receive the response from Bedrock.
    *   Return the response.
*   **Dependencies:** Ensure all necessary libraries (e.g., `boto3` for AWS interaction) are included in the Lambda deployment package.
*   **IAM Permissions:** Configure the Lambda function's IAM role to grant it permission to access Bedrock.  Ensure the role has the necessary permissions to invoke Bedrock models.

## 2. Create the API Gateway Endpoint

*   **Create API Gateway:** Set up an API Gateway endpoint that:
    *   Accepts POST requests.
    *   Integrates with your Lambda function.
*   **Configure CORS:** Enable Cross-Origin Resource Sharing (CORS) to allow your React app (hosted on S3) to make requests to the API Gateway.  This is crucial for browser-based applications.

## 3. Connect React Front-End to API Gateway

*   **Update `sendMessage`:** Modify the `sendMessage` function in your React app (`App.js`) to:
    *   Send a POST request to your API Gateway endpoint, including the user's message in the request body (e.g., using `fetch` or `axios`).
    *   Receive the response from the API Gateway.
    *   Display the response in the chat interface.
    *   Implement error handling to catch any issues during the API call (e.g., network errors, API errors).
*   **Remove Mock API:** Delete the `mockAPI` function from your `App.js` file.  This is no longer needed as you'll be using the real API.

## 4. Host React App on S3

*   **Build React App:** Create a production build of your React app using `npm run build` or `yarn build`.  This will create an optimized build in a `build` directory.
*   **Create S3 Bucket:** Create an S3 bucket to host your React app. Choose a globally unique name.
*   **Upload Files:** Upload the files from the `build` directory to your S3 bucket.
*   **Configure Static Website Hosting:** Enable static website hosting on your S3 bucket (in the S3 bucket properties). Specify `index.html` as the index document.
*   **Set Bucket Policy:** Configure the bucket policy to allow public read access to your files.  **Be cautious!**  Restrict access as much as possible. A basic policy might look like this (replace `your-bucket-name`):

    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "PublicReadGetObject",
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::your-bucket-name/*"
        }
      ]
    }
    ```

## 5. Test the Complete System

*   **Access React App:** Access your React app through the S3 bucket's website endpoint (found in the S3 bucket properties after enabling static website hosting).
*   **Send Messages:** Send messages through the chat interface.
*   **Verify Response:** Verify that the messages are sent to the Lambda function via API Gateway, processed by Bedrock, and the response is displayed correctly in the React app.
*   **Error Handling:** Test error scenarios to ensure the system handles them gracefully.  Try sending invalid input, simulating network outages, etc.

This streamlined plan focuses on getting the core functionality working first. Once you have this basic setup, you can then iterate and add more advanced features.

Install node.js from https://nodejs.org/.
## Verify
node -v
npm -v

## Create project for react

npx create-react-app s3chatbot-frontend
/Users/sandy4v/Documents/awsaipro.com/website files/awsaipro logo.png 
 -- Modify the files to have a working app

 ## build the app
npm run build

## S3 hosting 
    copy all the files and folder under the build directory to the s3 bucket and enable static web hosting

## Docker CICD Build
    we will create our own docker image with npm and nodejs installed 
    docker build -t jenkins-s3chatbot
    docker images
    docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins-s3chatbot
    
    http://localhost:8080/
    docker exec $(docker ps -q -f "ancestor=jenkins/jenkins:lts") cat /var/jenkins_home/secrets/initialAdminPassword
    docker ps -q -f "ancestor=jenkins/jenkins:lts"
    docker stop < container id>
    docker rm $(docker ps -aq)   # removes all the containers

