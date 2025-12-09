## 📖 Project Overview

This repository contains the source code and infrastructure definitions for my serverless cloud resume. This project was built as part of the **Cloud Resume Challenge**, a hands-on project designed to bridge the gap between certification and actual cloud experience.

The project demonstrates a full-stack serverless application deployed on AWS, utilizing Infrastructure as Code (IaC) for resource management and CI/CD pipelines for automated deployment.

### 🔗 Live Demo
You can view the live site here: **[Insert Your CloudFront URL Here]**

---

## 🏗️ Architecture Design

The application uses a serverless event-driven architecture. Below is a high-level overview of how the components interact:

```mermaid
graph TD
    User((Visitor))
    
    subgraph "Frontend Architecture"
        CF[CloudFront Distribution]
        S3[S3 Bucket\n(Static Website)]
    end
    
    subgraph "Backend Architecture"
        APIG[API Gateway]
        Lambda[AWS Lambda\n(Python/Boto3)]
        DDB[(DynamoDB Table)]
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
