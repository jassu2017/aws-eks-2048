# --- 1. AWS Provider ---
# provider "aws" {
#   region = var.aws_region
# }

# --- 2. Data Sources for EKS Cluster Details ---
# These fetch the necessary connection info and temporary token after the EKS cluster is created.
data "aws_eks_cluster" "eks_cluster_data" {
  name = var.cluster_name # Assuming cluster_name is defined in variables.tf
}

data "aws_eks_cluster_auth" "eks_cluster_auth_data" {
  name = var.cluster_name
}

# --- 3. Kubernetes Provider Configuration (FIX) ---
# This configures the Kubernetes provider to connect to EKS using the retrieved details.
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster_data.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster_data.certificate_authority[0].data)

  # Use the AWS CLI to generate the token dynamically for authentication
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks_cluster_data.name]
  }
}

# --- 4. Helm Provider Configuration (FIX) ---
# This configures the Helm provider to use the same connection details as the Kubernetes provider.
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster_data.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster_data.certificate_authority[0].data)

    # Use the AWS CLI to generate the token dynamically for authentication
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks_cluster_data.name]
    }
  }
}