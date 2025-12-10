variable "region" {
  description = "AWS region"
  type        = string
  default = "ap-south-1"

}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}