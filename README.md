# Cloud Run Hello Service

A Go web service running on Google Cloud Run, deployed and managed with Terraform. This project demonstrates infrastructure as code principles with a basic web application.

This is a simpler version of my [hello-cdk](https://github.com/jkarenko/hello-cdk) project that manages the infrastructure for the same Go service on AWS Fargate. It can be used as a jumping off point for projects in the same vein of App -> Docker -> IaC -> Cloud.

There's a number of currently undocumented steps for the gcloud CLI that I've done to get this working. I'll document them in the future.

## Overview

This project implements:
- A Go web service with basic endpoints
- Cloud Run deployment with VPC networking
- Infrastructure automation with Terraform
- Container registry management
- Automated build and deployment pipeline

## Prerequisites

- Google Cloud Platform account
- Terraform installed
- Docker installed
- Configured gcloud CLI
- Service account with appropriate permissions

## Setup

1. Clone the repository
2. Place your service account key in `terraform-key.json`
3. Initialize Terraform:

   ```bash
   terraform init
   ```
4. Deploy the infrastructure:

   ```bash
   terraform apply
   ```

## API Endpoints

The service provides the following endpoints:
- `/` - Endpoint listing
- `/hello` - Default greeting
- `/hello?name={name}` - Personalized greeting
- `/health` - Health check endpoint

## Components

### Application
- Go web service
- Docker containerization
- Automated build process

### Infrastructure
- VPC network and subnet
- Cloud Run service with autoscaling
- VPC Access Connector
- Artifact Registry repository
- Google Cloud API enablement
- IAM configuration

## Configuration

- Region: `europe-north1`
- Scaling: 1-2 instances
- Resources: 1 CPU, 512Mi memory
- VPC Connector: `/28` CIDR range
- State Storage: Google Cloud Storage

## Development

Local development:

```bash
go run main.go
```

Container build:

```bash
docker build -t hello-app .
```

## State Management

Terraform state is maintained in Google Cloud Storage, enabling team collaboration and state consistency.
