## 📖 Project Overview

This repository contains the source code and infrastructure definitions for my serverless cloud resume. This project was built as part of the **Cloud Resume Challenge**, a hands-on project designed to bridge the gap between certification and actual cloud experience.

The project demonstrates a full-stack serverless application deployed on AWS, utilizing Infrastructure as Code (IaC) for resource management and CI/CD pipelines for automated deployment.

### 🔗 Live Demo
You can view the live site here: **[Insert Your CloudFront URL Here]**

---

## 🏗️ Architecture Design

The application uses a serverless event-driven architecture. Below is a high-level overview of how the components interact:

graph TD
    User((Visitor))
    
    subgraph "Frontend Architecture"
        CF[CloudFront Distribution]
        S3["S3 Bucket <br> (Static Website)"]
    end
    
    subgraph "Backend Architecture"
        APIG[API Gateway]
        Lambda["AWS Lambda <br> (Python/Boto3)"]
        DDB[("DynamoDB Table")]
    end

    subgraph "CI/CD Pipeline"
        GH[GitHub Actions]
    end

    %% Flows
    User -- "HTTPS Request" --> CF
    CF -- "Origin Fetch (HTML/CSS/JS)" --> S3
    
    User -- "JS API Call (Count Visitor)" --> APIG
    APIG -- "Invokes" --> Lambda
    Lambda -- "Atomic Update/Read" --> DDB
    
    %% CICD Flows
    GH -- "Deploys Infrastructure" --> APIG & Lambda & DDB
    GH -- "Syncs Static Files" --> S3
    GH -- "Invalidates Cache" --> CF

    
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
