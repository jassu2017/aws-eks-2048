variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}



variable "vpc_id" {
  description = "My VPC ID for EKS cluster"
  type        = string
}

variable "subnet_ids" {
   description = "Subnet ID"
   type        = list(string)
}

variable "security_group_ids" {
  description = "SG"
  type = list(string)
  
}



variable "eks_cluster_name" {
  description = "The name of my EKS cluster"
  type        = string
}


variable "cluster_version" {
  description = "My cluster version"
  type        = string
}



# variable "node_groups" {
#   description = "EKS node group configuration variable"

#   type = map(
#     object({
#       instance_types = list(string)
#       capacity_type  = string

#       scaling_config = object({
#         desired_size = number
#         max_size     = number
#         min_size     = number
#       })
#     })
#   )
# }

