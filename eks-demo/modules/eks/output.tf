output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main-eks-cluster.endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.main-eks-cluster.name
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for the cluster."
  value       = aws_eks_cluster.main-eks-cluster.identity[0].oidc[0].issuer
}

output "cluster_security_group_id" {
  description = "The security group ID created by EKS for the control plane."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}