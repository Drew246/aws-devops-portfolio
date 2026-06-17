# AWS & DevOps Portfolio

I'm Andrew McCollin, an AWS & DevOps engineer in training currently pursuing the AWS Solutions Architect Associate certification. This repository documents my hands-on learning journey — each project is built with real AWS services and provisioned with Terraform as Infrastructure as Code. I'm based in Barbados and open to remote opportunities in cloud and DevOps engineering.

---

## Certifications

| Certification | Status |
|--------------|--------|
| CompTIA Security+ | ✅ Certified |
| AWS Solutions Architect Associate | 🔨 In Progress |

---

## Skills

| Category | Technologies |
|----------|-------------|
| Cloud | AWS (S3, CloudFront, Route 53, ACM, ECS, ECR, ALB, VPC, Lambda, API Gateway, DynamoDB, CloudWatch) |
| Infrastructure as Code | Terraform |
| Containers | Docker, ECS Fargate |
| CI/CD | GitHub Actions |
| Languages | Python |

---

## Projects

### 1. Static Website — S3 + CloudFront + Route 53
> Status: ✅ Complete

Hosts a static portfolio website on S3, served globally via CloudFront CDN, secured with an ACM SSL certificate and custom domain managed through Route 53. All infrastructure provisioned with Terraform.

**Live URL:** [andrewmccollin.tech](https://andrewmccollin.tech)

**AWS Services:** S3, CloudFront, Route 53, ACM  
**DevOps Tools:** Terraform

---

### 2. Containerised App — ECS Fargate + ALB + CI/CD Pipeline
> Status: ✅ Complete

A Python Flask web application containerised with Docker and deployed to AWS ECS Fargate. Infrastructure includes a custom VPC with public subnets across two Availability Zones, an Application Load Balancer for traffic distribution and health checking, ECR for private image storage, and CloudWatch for container logging. A GitHub Actions CI/CD pipeline automatically builds, pushes and deploys the container on every code push to main.

**AWS Services:** ECS Fargate, ECR, ALB, VPC, CloudWatch  
**DevOps Tools:** Terraform, Docker, GitHub Actions

---

### 3. Serverless File Processing App — Lambda + API Gateway + S3
> Status: 🔨 Coming Soon

A serverless file processing application with a web frontend. Users upload files through an API Gateway endpoint, Lambda processes them, results are stored in S3, and metadata is saved to DynamoDB.

**AWS Services:** Lambda, API Gateway, S3, DynamoDB  
**DevOps Tools:** Terraform

---