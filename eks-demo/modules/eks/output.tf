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
  value       = aws_eks_cluster.main-eks-cluster.vpc_config[0].security_group_ids
}

# output "cluster_security_group_id" {
#   description = "The security group ID created by EKS for the control plane."
#   #value       = aws_eks_cluster.main_eks_cluster.vpc_config[0].cluster_security_group_id
#   value = module.eks.vpc_config[0].cluster_security_group_id
# }

output "fargate_egress_security_group_id" {
  description = "The ID of the custom security group for Fargate Pod egress."
  value       = aws_security_group.fargate_egress.id
}