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
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 2.17"
    # }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 2.38"
    # }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {

  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
  
}