# Project 17: AI Developer Platform

## Overview

Internal Developer Platform using Backstage on hybrid AWS EKS/ECS architecture. MLflow for model registry. ArgoCD for GitOps deployments. Custom cost tracking service on ECS Fargate.

## Architecture

### Hybrid Cloud Strategy
- EKS Cluster: Backstage, MLflow, ArgoCD
- ECS Fargate: Cost tracking service
- Decision logic: Stateful/complex services on EKS, stateless services on ECS

### Core Components

1. **Backstage Developer Portal**
   - Service catalogue with templates
   - GPU-optimised deployment templates
   - Integration with Git repositories

2. **ArgoCD GitOps Engine**
   - Automated deployments from Git commits
   - Declarative infrastructure management
   - Application synchronisation

3. **MLflow Model Registry**
   - Model versioning
   - Experiment tracking
   - Deployment pipeline integration

4. **GPU Cost Tracker**
   - Custom Node.js/Express application
   - Deployed on ECS Fargate
   - Real-time monitoring dashboard

## Technologies Used

### Platform Layer
- Kubernetes (EKS): v1.28 - Container orchestration
- ECS Fargate: Serverless containers
- Backstage: v1.9.0 - Developer portal framework
- ArgoCD: v2.9 - GitOps continuous delivery
- MLflow: v2.10 - ML lifecycle management

### Infrastructure
- Terraform: v1.5 - Infrastructure as Code
- AWS: EKS, ECS, ECR, ALB, VPC
- Helm: v3 - Kubernetes package management

### Monitoring
- Custom Cost Tracker: Node.js/Express
- Prometheus: Metrics collection

## Project Structure

```
project-17-ai-developer-platform/
├── terraform/
│   ├── eks/                    # EKS cluster configuration
│   ├── ecs/                    # ECS Fargate services
│   ├── networking/             # VPC and ALB
│   └── main.tf                 # Root module
├── backstage/
│   ├── app-config.yaml         # Platform configuration
│   ├── catalog/                # Service templates
│   └── plugins/                # Custom plugins
├── argocd/
│   ├── applications/           # Application definitions
│   └── app-of-apps.yaml        # Bootstrap configuration
├── mlflow/
│   ├── values.yaml             # Helm values
│   └── deployment.yaml         # Kubernetes deployment
└── cost-tracker/
    ├── src/                    # Node.js application
    ├── Dockerfile              # Container image
    └── task-definition.json    # ECS task definition
```

## Implementation

### Infrastructure Provisioning
- Terraform creates VPC with public and private subnets
- EKS cluster with managed node groups
- ECS cluster for Fargate services
- Application Load Balancer for ingress

### Platform Services
- Backstage deployed via Helm on EKS
- ArgoCD installed using official Helm chart
- MLflow configured with S3 backend
- Cost Tracker deployed as ECS Fargate task

### CI/CD Pipeline
```
Validate (Security Scan) → Build (Docker) → Deploy (ECS) → Update (ArgoCD)
```
- Trivy security scanning
- Docker builds to ECR
- Automated deployments

### Model Deployment Templates
- TensorFlow Serving configuration
- PyTorch TorchServe setup
- HuggingFace Transformers deployment
- Custom FastAPI wrapper

## Features

### Self-Service Capabilities
- Environment provisioning templates
- GPU resource allocation configurations
- Model deployment automation
- Service catalogue management

### Developer Portal
- Golden path templates
- Service documentation
- Dependency mapping
- Team ownership tracking

### GitOps Workflow
- Git as single source of truth
- Automated synchronisation
- Drift detection
- Self-healing infrastructure

## Screenshots

1. ArgoCD dashboard showing deployments
2. Cost Tracker web interface
3. Backstage portal with service catalogue
4. MLflow registry with model versions

## Deployment Process

1. Terraform provisions AWS infrastructure
2. EKS cluster configured with add-ons
3. Backstage deployed via Helm
4. ArgoCD bootstrapped with app-of-apps pattern
5. MLflow installed with S3 integration
6. Cost Tracker deployed to ECS Fargate
7. Templates configured in Backstage catalogue