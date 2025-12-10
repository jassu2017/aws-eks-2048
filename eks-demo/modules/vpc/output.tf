# VPC ID output is essential for associating other resources within the VPC.
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.eks_vpc.id
}

# Public subnet IDs are required for routing internet-facing traffic and public services.
output "public_subnet_ids" {
  description = "public subnet IDs"
  value       = aws_subnet.eks-public-subnet[*].id
}

# Private subnet IDs are necessary for isolating internal resources and worker nodes.
output "private_subnet_ids" {
  description = "private subnet IDs"
  value       = aws_subnet.eks-private-subnet[*].id
}