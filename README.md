## 📖 Project Overview

This repository contains the source code and infrastructure definitions for my serverless cloud resume. This project was built as part of the **Cloud Resume Challenge**, a hands-on project designed to bridge the gap between certification and actual cloud experience.

The project demonstrates a full-stack serverless application deployed on AWS, utilizing Infrastructure as Code (IaC) for resource management and CI/CD pipelines for automated deployment.

---

## 🏗️ Architecture Design

The application uses a serverless event-driven architecture. Below is a high-level overview of how the components interact:


<img width="2076" height="1278" alt="mermaid-diagram-2025-12-09-232753" src="https://github.com/user-attachments/assets/655a71a2-25ea-4274-aff6-3180824b89b3" />

 Data Flow & Technical Details
Here is the detailed breakdown of how the request travels from the user to the database and back:
1. The Frontend (Static Content)
S3 & CloudFront: The resume website is a static HTML/CSS template hosted in an Amazon S3 bucket.
Security & Caching: To ensure security and performance, the S3 bucket is not exposed directly to the public. Instead, it is fronted by Amazon CloudFront, a Content Delivery Network (CDN). This enforces HTTPS via SSL/TLS and caches the content at edge locations globally to reduce latency.
2. The Visitor Counter (The "Dynamic" Part)
When the website loads, a small snippet of JavaScript executes to track the visitor count:
API Call: The browser sends a fetch() request to the backend API endpoint.
API Gateway: AWS API Gateway receives the request. It acts as the "front door" for the backend, handling CORS (Cross-Origin Resource Sharing) checks to ensure only my specific domain can trigger the function.
Compute: The Gateway triggers an AWS Lambda function written in Python.
Database Interaction: The Lambda function uses the boto3 library to communicate with Amazon DynamoDB. It performs an atomic update operation to increment the visitor count field and returns the updated value.
Response: The count travels back through the Lambda > API Gateway > Browser chain and is updated in the HTML DOM for the user to see.

Infrastructure & Automation
This project follows DevOps best practices, ensuring no manual configuration is done in the AWS Console.
Infrastructure as Code (IaC)
All AWS resources (S3, CloudFront, DynamoDB, API Gateway, Lambda) are defined as code using AWS SAM (Serverless Application Model).
This ensures the infrastructure is reproducible, version-controlled, and modular.
CI/CD Pipelines (GitHub Actions)
I have set up two separate Continuous Integration/Continuous Deployment workflows:
Frontend Pipeline:
Triggers on changes to the HTML/CSS code.
Automatically syncs files to the S3 bucket.
Invalidates the CloudFront cache to ensure users see the latest version immediately.
Backend Pipeline:
Triggers on changes to the Python code or SAM template.
Runs a Python Unit Test suite to verify the Lambda logic works as expected.
Builds and deploys the updated CloudFormation stack to AWS.


