variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidr" {
  description = "public subnet CIDR block"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "public subnet CIDR block"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}


variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}