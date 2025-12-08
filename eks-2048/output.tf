output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "kubeconfig_command" {
  description = "The command to update your kubeconfig file"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# The OIDC ARN you need for the ALB Controller IAM Role
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}