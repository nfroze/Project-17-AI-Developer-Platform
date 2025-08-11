output "platform_endpoints" {
  value = {
    cost_tracker_ecs = "http://${aws_lb.cost_tracker.dns_name}"
    eks_cluster      = module.eks.cluster_endpoint
    ecr_repository   = aws_ecr_repository.cost_tracker.repository_url
  }
}

output "deployment_instructions" {
  value = <<-EOT
    
    ========================================
    AI Platform Deployed Successfully!
    ========================================
    
    Architecture:
    - EKS: Platform services (ArgoCD, MLflow, Backstage)
    - ECS Fargate: Cost Tracker (70% cheaper for simple services)
    
    To access services:
    1. Cost Tracker (ECS): http://${aws_lb.cost_tracker.dns_name}
    2. Configure kubectl: aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}
    3. Port-forward to access EKS services:
       - ArgoCD: kubectl port-forward svc/argocd-server -n argocd 8080:80
       - MLflow: kubectl port-forward svc/mlflow -n mlflow 5000:5000
       - Backstage: kubectl port-forward svc/backstage -n backstage 7007:7007
    
    To destroy: terraform destroy -auto-approve
  EOT
}