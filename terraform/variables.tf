variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "ai-platform-demo"
}

variable "instance_type" {
  description = "EC2 instance type for EKS nodes"
  default     = "t3.medium"
}

variable "environment" {
  description = "Environment name"
  default     = "demo"
}