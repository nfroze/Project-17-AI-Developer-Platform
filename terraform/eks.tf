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

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}