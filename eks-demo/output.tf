output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

# VPC ID output is essential for associating other resources within the VPC.
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# Public subnet IDs are required for routing internet-facing traffic and public services.
output "public_subnet_ids" {
  description = "public subnet IDs"
  #value       = aws_subnet.eks-public-subnet[*].id
  value = module.vpc.public_subnet_ids
}

# Private subnet IDs are necessary for isolating internal resources and worker nodes.
output "private_subnet_ids" {
  description = "private subnet IDs"
  #value       = aws_subnet.eks-private-subnet[*].id
  value = module.vpc.private_subnet_ids

}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for the cluster."
  #value       = aws_eks_cluster.main-eks-cluster.identity[0].oidc[0].issuer
  value = module.eks.oidc_issuer_url
}

output "cluster_security_group_id" {
  description = "The security group ID created by EKS for the control plane."
  #value       = aws_eks_cluster.main-eks-cluster.vpc_config[0].security_group_ids
  value = module.eks.cluster_security_group_id
}

# output "cluster_security_group_id" {
#   description = "The security group ID created by EKS for the control plane."
#   #value       = aws_eks_cluster.main_eks_cluster.vpc_config[0].cluster_security_group_id
#   value = module.eks.vpc_config[0].cluster_security_group_id
# }

output "fargate_egress_security_group_id" {
  description = "The ID of the custom security group for Fargate Pod egress."
  #value       = aws_security_group.fargate_egress.id
  value = module.eks.fargate_egress_security_group_id
}