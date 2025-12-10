# VPC Configuration
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr  # TODO: Define VPC CIDR in variables.tf
  enable_dns_hostnames = true  
  enable_dns_support   = true  

  tags = {
    Project     = "EKS-Cluster"
    Environment = "demo"# TODO: Modify the environment tag""
  }
}