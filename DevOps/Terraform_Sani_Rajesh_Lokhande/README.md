# AWS Infrastructure Automation with Terraform

**Project:** DevOps Deployment (Flask Backend + Express Frontend)  
**Author:** Sani Rajesh Lokhande  
**Repository:** [Sanilkhande06/Tutedude](https://github.com/Sanilkhande06/Tutedude)  
**Directory:** `DevOps/Terraform_Sani_Rajesh_Lokhande`

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture Comparison](#architecture-comparison)
3. [Repository Structure](#repository-structure)
4. [Prerequisites](#prerequisites)
5. [Terraform State Management (S3 Backend)](#terraform-state-management-s3-backend)
6. [Part 1: Monolithic Deployment on a Single EC2](#part-1-monolithic-deployment-on-a-single-ec2)
7. [Part 2: Decoupled Multi-EC2 Deployment with Custom VPC](#part-2-decoupled-multi-ec2-deployment-with-custom-vpc)
8. [Part 3: Containerized Microservices via ECR, ECS & ALB](#part-3-containerized-microservices-via-ecr-ecs--alb)
9. [Verification and Testing](#verification-and-testing)
10. [Resource Cleanup & Teardown](#resource-cleanup--teardown)

---

## Project Overview

This repository demonstrates the progressive infrastructure evolution of a two-tier web application consisting of a **Python Flask Backend** and a **Node.js Express Frontend**. 

Using HashiCorp Terraform as the Infrastructure as Code (IaC) tool, the project evolves through three architecture paradigms:
- **Part 1:** Colocated monolithic deployment on a single EC2 instance using Cloud-Init / User Data.
- **Part 2:** Decoupled deployment isolating the backend and frontend across two dedicated EC2 instances inside a custom VPC with granular Security Group policies.
- **Part 3:** Cloud-native containerized architecture using Docker, Amazon ECR, Amazon ECS (Fargate), and an Application Load Balancer (ALB).

---

## Architecture Comparison

| Feature | Part 1: Single EC2 | Part 2: Dual EC2 | Part 3: ECS Microservices |
|---|---|---|---|
| **Compute** | 1x EC2 (`t2.micro` / `t3.micro`) | 2x EC2 instances | AWS ECS (Fargate Serverless) |
| **Networking** | Default VPC or Simple Subnet | Custom VPC (`10.0.0.0/16`) + Custom Subnets | Custom Multi-AZ VPC + Public/Private Subnets |
| **Frontend Access** | Port `3000` on Public IP | Port `3000` on Express Public IP | Port `80` via Application Load Balancer (ALB) |
| **Backend Access** | Port `5000` on Public IP | Port `5000` (Restricted to Express SG) | Target Group routing via ALB (`/api/*`) |
| **Packaging** | Direct OS execution via User Data | Direct OS execution via User Data | Docker Images published to Amazon ECR |
| **State Storage** | S3 Key: `part1/terraform.tfstate` | S3 Key: `part2/terraform.tfstate` | S3 Key: `part3/terraform.tfstate` |

---

## Repository Structure

```text
Terraform_Sani_Rajesh_Lokhande/
│
├── Task1/                             # Part 1: Single EC2 Deployment
│   ├── main.tf                        # EC2, Security Group & provider configuration
│   ├── variables.tf                   # Input variables (AMI, instance type, key pair)
│   ├── terraform.tfvars               # Variable definitions
│   └── backend.tf
|   └── templates
|   └── install-packeges.yml
├── Task2/                             # Part 2: Dual EC2 Instances in Custom VPC
│   ├── main.tf                        # EC2 instances for Flask and Express
│   ├── templates                         # Custom VPC, subnets, IGW & route tables
│   ├── backend_packeges.yml             # Frontend & Backend isolation rules
│   ├── frontned_packeges.yml 
│   └── backend.tf
│   ├── variables.tf                   # Input variables
│   ├── terraform.tfvars
│
├── Task3/                             # Part 3: Containerized Microservices
│   ├── main.tf                        
│   ├── backend.tf                       
│   ├── docker_ecr_image_push.yml      # ECR repositories for Flask & Express
│   ├── variables.tf                   # Input variables
│   ├── outputs.tf                     
│   └── terraform.tfvars
│
└── README.md

```

Prerequisites
Ensure you have installed and configured the following on your machine:

```sh
AWS CLI (v2.x): Configured with valid IAM credentials (aws configure)

Terraform: >= 1.5.0

Docker Engine: Installed and running locally

Git
```

Terraform State Management (S3 Backend)
All three projects maintain independent remote state files in Amazon S3 to prevent accidental state corruption, enable collaboration, and isolate environments.

1. One-Time Bucket Creation
Run the AWS CLI command to create the bucket once (replace with your globally unique bucket name):

```sh
aws s3 mb s3://sani-terraform-state-bucket-2026 --region eu-north-1
```
2. Backend Declarations
Each part points to this bucket using a dedicated key path inside its respective main.tf:

```sh
Part 1:

Terraform
terraform {
  backend "s3" {
    bucket = "sani-terraform-state-bucket-101010"
    key    = "Task1/terraform.tfstate"
    region = "eu-north-1"
  }
}
```
```sh
Part 2:

Terraform
terraform {
  backend "s3" {
    bucket = "sani-terraform-state-bucket-101010"
    key    = "Task2/terraform.tfstate"
    region = "eu-north-1"
  }
}
```
```sh
Part 3:

Terraform
terraform {
  backend "s3" {
    bucket = "sani-terraform-state-bucket-101010"
    key    = "Task3/terraform.tfstate"
    region = "eu-north-1"
  }
}
```


Part 1: Monolithic Deployment on a Single EC2

Objective
Provisions a single EC2 instance using Terraform. A user_data.sh script automates the installation of system packages (Python, pip, Node.js, npm) and runs both applications concurrently on different ports.

Express Frontend: Port 3000

Flask Backend: Port 5000

Deployment Steps

```sh
cd Task_1_Single_Instance
terraform init
terraform plan
terraform apply tfplan
Outputs & Verification
```

```sh
# Get the instance public IP
INSTANCE_IP=$(terraform output -raw server_public_ip)

# Test the Express Frontend
curl http://${INSTANCE_IP}:3000

# Test the Flask Backend
curl http://${INSTANCE_IP}:5000/students

```

Part 2: Decoupled Multi-EC2 Deployment with Custom VPC

Objective
Decouples the frontend and backend onto two separate EC2 instances within a custom Virtual Private Cloud (VPC). Network security is enforced using least-privilege Security Groups:

```sh
Express SG: Allows inbound HTTP traffic on port 3000 from the internet (0.0.0.0/0).
```

Flask SG: Allows inbound traffic on port 5000 strictly from the Express Security Group ID, isolating the backend API from direct internet access.

Deployment Steps
```sh
cd ../Task_2_Two_Instances
terraform init
terraform plan 
terraform apply 
```
Outputs & Verification

```sh
EXPRESS_IP=$(terraform output -raw server_public_ip[0])
FLASK_IP=$(terraform output -raw server_public_ip[1])
```

### Query Express application (Public)

curl http://${EXPRESS_IP}:3000

### Test Flask Backend directly (should succeed only if allowed by SG or tested from within the VPC)
curl http://${FLASK_IP}:5000/students


# Part 3: Containerized Microservices via ECR, ECS & ALB
Objective
Packages the Flask backend and Express frontend as Docker containers, pushes the images to Amazon ECR repositories, and deploys them to Amazon ECS using AWS Fargate behind an Application Load Balancer (ALB).

AWS ECR: Container image registries.

AWS ECS (Fargate): Serverless container compute running task definitions for both services.

Application Load Balancer (ALB): Single public entry point routing requests based on HTTP listener paths.

Deployment Steps
Step 3.1: Create ECR Repositories

```sh
cd ../Task_3_Docker_AWS_Services
terraform init
terraform apply -auto-approve
```

Step 3.2: Build, Tag, and Push Docker Images
```sh
AWS_REGION="eu-north-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_FLASK_URL=$(terraform output -raw flask_ecr_repository_url)
ECR_EXPRESS_URL=$(terraform output -raw express_ecr_repository_url)
```

## Authenticate Docker daemon to Amazon ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

## Build and push Flask Backend
docker build -t flask-backend ../app/backend
docker tag flask-backend:latest ${ECR_FLASK_URL}:latest
docker push ${ECR_FLASK_URL}:latest

## Build and push Express Frontend
docker build -t express-frontend ../app/frontend
docker tag express-frontend:latest ${ECR_EXPRESS_URL}:latest
docker push ${ECR_EXPRESS_URL}:latest
Step 3.3: Deploy Networking, ALB, and ECS Services

```sh
terraform plan -out=tfplan
terraform apply tfplan
Outputs & Verification
```

```sh
# Get the Application Load Balancer DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Access Express Frontend (Default route)
curl http://${ALB_DNS}/

# Access Flask Backend API (Path-based route)
curl http://${ALB_DNS}/api
```