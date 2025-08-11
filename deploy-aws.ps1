# PowerShell script for Windows
Write-Host "🚀 Deploying AI Platform to AWS (EKS + ECS) in EU-WEST-2..." -ForegroundColor Green

# Variables
$REGION = "eu-west-2"
$ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
$ECR_REGISTRY = "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# Build and push Docker image
Write-Host "📦 Building Cost Tracker Docker image..." -ForegroundColor Yellow
Set-Location custom-services/gpu-cost-tracker
docker build -t gpu-cost-tracker .

Write-Host "🔐 Logging into ECR..." -ForegroundColor Yellow
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

Write-Host "📤 Pushing to ECR..." -ForegroundColor Yellow
docker tag gpu-cost-tracker:latest ${ECR_REGISTRY}/gpu-cost-tracker:latest
docker push ${ECR_REGISTRY}/gpu-cost-tracker:latest
Set-Location ../..

# Deploy Terraform
Write-Host "🏗️ Deploying infrastructure in EU-WEST-2..." -ForegroundColor Yellow
Set-Location terraform
terraform init
terraform apply -auto-approve

Write-Host "✅ Deployment complete!" -ForegroundColor Green
terraform output

Set-Location ..