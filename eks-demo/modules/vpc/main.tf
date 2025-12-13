# VPC Configuration
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr  # TODO: Define VPC CIDR in variables.tf
  enable_dns_hostnames = true  
  enable_dns_support   = true  

  tags = {
    Name        = "eks-vpc"
    Project     = "EKS-Cluster"
    Environment = "demo"# TODO: Modify the environment tag""
  }
}

# Public Subnets
resource "aws_subnet" "eks-public-subnet" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.public_subnet_cidr[count.index] # TODO
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true  # Automatically assign a public IP address to instances

  tags = {
    #Name    = "eks-public-subnet-${count.index + 1}"  # TODO: Customize naming pattern
    Name = "PublicSubnet-${var.availability_zones[count.index]}"
    # CRITICAL: ALB Controller uses this tag to find public subnets
    "kubernetes.io/role/elb" = "1" 
    # Recommended cluster tag (optional for LBC > v2.1.2, but good practice)
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    Tier    = "public"
  }
}

resource "aws_subnet" "eks-private-subnet" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]# TODO: Add availability zone 
  availability_zone = var.availability_zones[count.index]# TODO: Add availability zone 

  map_public_ip_on_launch = false  # Automatically assign a public IP address to instances

  tags = {
    #Name    = "eks-private-subnet-${count.index + 1}"  # TODO: Customize naming pattern
    Tier    = "private"
    Name = "PrivateSubnet-${var.availability_zones[count.index]}"
    # Optional: For internal-facing ALBs, but not needed for your public ALB
    # "kubernetes.io/role/internal-elb" = "1" 
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "int-gw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-IG" # TODO: Add tag name
  }
}

# Elastic IPs
resource "aws_eip" "eip-nat" {
  count = length(var.public_subnet_cidr)  # TODO: Add public subnet cidr
  domain = "vpc"

  tags = {
    Project = "EKS-Cluster"
  }

    # TODO: Optionally add tags here for better resource tracking
}

#NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  count         = length(var.public_subnet_cidr)  # TODO: Add public subnet cidr
  allocation_id = aws_eip.eip-nat[count.index].id  
  subnet_id     = aws_subnet.eks-public-subnet[count.index].id

  tags = {
    Name = "eks-nat-gateway-${count.index + 1}"
  }
}

# Route Tables
resource "aws_route_table" "eks-public-rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Allows all outbound traffic
    gateway_id = aws_internet_gateway.int-gw.id
  }

  tags = {
    Name = "eks-public-RT"    # TODO: Add tag name
  }
}

resource "aws_route_table" "eks-private-rt" {
  count = length(var.private_subnet_cidr)   #   Replace with private subnet cidr
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw[count.index].id
  }

  tags = {
    Name = "eks-private-RT-${count.index + 1}"  # TODO: Customize prefix or suffix if needed
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.eks-private-subnet[count.index].id
  route_table_id = aws_route_table.eks-private-rt[count.index].id
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.eks-public-subnet[count.index].id
  route_table_id = aws_route_table.eks-public-rt.id
}

