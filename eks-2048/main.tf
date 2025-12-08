# Define the AWS Provider
terraform {

  required_version = ">=1.3.0"

  cloud {
    organization = "AWS-TF-GH-CODESPACE"
    workspaces {
      name = "aws-terraform-codespace"
    }
  }  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- 1. Provision VPC and Networking (Replicates eksctl's network setup) ---

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.cluster_name
  cidr = var.vpc_cidr

  azs             = [for i in range(length(var.private_subnets)) : "${var.aws_region}${element(["a", "b", "c"], i)}"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  enable_nat_gateway = true
  single_nat_gateway = true # For simplicity and cost-saving
  
  tags = {
    # Crucial tags for EKS discovery
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
  
  public_subnet_tags = {
    # Crucial tags for ALB discovery
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    # Crucial tags for ALB/Worker discovery
    "kubernetes.io/role/internal-elb" = 1
  }
}

# --- 2. Provision EKS Cluster with Fargate (Replicates eksctl cluster and fargate profile) ---

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0" # Use a stable, recent version

  #cluster_name    = var.cluster_name
  #cluster_version = "1.29" # Use a stable, recent version
 # The OIDC provider will be created automatically.
  # Do not use `create_oidc_provider` or `enable_cluster_creator_role`
  # as they are deprecated or renamed in recent versions.

  name                   = var.cluster_name
  kubernetes_version     = "1.30"
  #endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets # EKS control plane uses private subnets
  control_plane_subnet_ids = module.vpc.public_subnets  # Use public subnets to allow external access to API endpoint (default eksctl behavior)
  
  # Enable OIDC provider for IRSA (required for ALB Controller)
  #enable_cluster_creator_role = false
  #create_oidc_provider        = true
  
  # --- Fargate Profile Configuration (Matches video's serverless worker nodes) ---
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        { namespace = "kube-system" },
        { namespace = "default" }
      ]
    }
    game2048 = {
      name = "game2048-profile"
      selectors = [
        { namespace = "game2048" }
      ]
      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = {
    Environment = "DevOpsDemo"
    Project     = var.cluster_name
  }
}