module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    demo = {
      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = [var.instance_type]
      
      labels = {
        Environment = var.environment
        Platform    = "ai-developer"
        NodeType    = "general"
      }
      
      tags = {
        Environment = var.environment
      }
    }
  }

  tags = {
    Environment = var.environment
    Platform    = "ai-developer"
  }
}

# Deploy ArgoCD
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.4"
  namespace        = "argocd"
  create_namespace = true

  values = [file("${path.module}/../helm-values/argocd-values.yaml")]
  
  depends_on = [module.eks]
}

# Deploy MLflow
resource "helm_release" "mlflow" {
  name             = "mlflow"
  repository       = "https://community-charts.github.io/helm-charts"
  chart            = "mlflow"
  version          = "0.7.19"
  namespace        = "mlflow"
  create_namespace = true

  values = [file("${path.module}/../helm-values/mlflow-values.yaml")]
  
  depends_on = [module.eks]
}

# Deploy Backstage
resource "helm_release" "backstage" {
  name             = "backstage"
  repository       = "https://backstage.github.io/charts"
  chart            = "backstage"
  version          = "1.9.0"
  namespace        = "backstage"
  create_namespace = true

  values = [file("${path.module}/../helm-values/backstage-values.yaml")]
  
  depends_on = [module.eks]
}

# Get EKS cluster auth
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}