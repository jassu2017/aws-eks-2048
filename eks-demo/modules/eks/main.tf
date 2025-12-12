# --- 1. IAM Role for Fargate Pod Execution (UNCHANGED) ---

# This role is required by Fargate to make AWS API calls (e.g., creating ENIs, writing logs).
resource "aws_iam_role" "eks_fargate_pod_execution_role" {
  name = "${aws_eks_cluster.main-eks-cluster.name}-fargate-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      },
    ]
  })
}

# --- 2. Attach Fargate Pod Execution Policy (UNCHANGED) ---

resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_pod_execution_role.name
}

# --- 3. Fargate Profile for System Pods (e.g., CoreDNS - Recommended to keep) ---

resource "aws_eks_fargate_profile" "system_fargate_profile" {
  cluster_name           = aws_eks_cluster.main-eks-cluster.name
  fargate_profile_name   = "fp-system"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn

  # CRITICAL: Use the PRIVATE SUBNET IDs
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "kube-system" # Targets system pods like CoreDNS
  }

  # --- EXPLICIT DEPENDENCIES ADDED ---
  depends_on = [
    aws_eks_cluster.main-eks-cluster,                  # Ensure the Cluster is ACTIVE first
    aws_iam_role_policy_attachment.eks_fargate_pod_execution_policy # Ensure the Role has policies attached
  ]
}

# --- 4. NEW Fargate Profile for the 'game2048' Application ---

resource "aws_eks_fargate_profile" "game2048_app_fargate_profile" {
  cluster_name           = aws_eks_cluster.main-eks-cluster.name
  fargate_profile_name   = "game2048" # The new profile name
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn

  # CRITICAL: Use the PRIVATE SUBNET IDs
  subnet_ids             = var.subnet_ids

  # The selector now targets ALL Pods in the 'game2048' namespace
  selector {
    namespace = "game2048" 
    # If you only want specific pods, you can add a label selector here:
    # labels = {
    #   app = "my-game-app" 
    # }
  }

  # --- EXPLICIT DEPENDENCIES ADDED ---
  depends_on = [
    aws_eks_cluster.main-eks-cluster,                  # Ensure the Cluster is ACTIVE first
    aws_iam_role_policy_attachment.eks_fargate_pod_execution_policy # Ensure the Role has policies attached
  ]
}

# IAM Role for EKS cluster

resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.cluster_version}-eks-cluster-role"



  assume_role_policy = jsonencode({

    Version = "2012-10-17",

    Statement = [{

      Action = "sts:AssumeRole",

      Effect = "Allow",

      Principal = {

        Service = "eks.amazonaws.com"

      }

    }]

  })

}


# Attach EKS Cluster Policy to Cluster Role

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}



# Create EKS Cluster

resource "aws_eks_cluster" "main-eks-cluster" {
  name     = var.eks_cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

##################################################################

# # --- OIDC Provider for IRSA ---

# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.main-eks-cluster.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.main-eks-cluster.identity[0].oidc[0].issuer
# }

# # --- LBC IAM Policy and Role ---

# # The AWS-required IAM Policy for the LBC. Create this policy from the AWS JSON documentation.
# resource "aws_iam_policy" "lbc_policy" {
#   name        = "AWSLoadBalancerControllerIAMPolicy-${var.eks_cluster_name}"
#   description = "Required permissions for the AWS Load Balancer Controller"
#   # NOTE: The content of the policy must be the JSON from the AWS documentation. 
#   # You should load the content from a local file (e.g., file("iam_policy.json"))
#   policy      = file("${path.module}/iam-policy.json") 
# }

# # The IAM Role the LBC Service Account will assume (IRSA)
# resource "aws_iam_role" "lbc_role" {
#   name = "aws-load-balancer-controller-${var.eks_cluster_name}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Effect = "Allow"
#       Principal = {
#         Federated = aws_iam_openid_connect_provider.eks.arn
#       }
#       Condition = {
#         # Restrict assumption to the LBC Service Account in the 'kube-system' namespace
#         StringEquals = {
#           "${aws_iam_openid_connect_provider.eks.url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#         }
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lbc_policy_attach" {
#   policy_arn = aws_iam_policy.lbc_policy.arn
#   role       = aws_iam_role.lbc_role.name
# }


# # --- AWS Load Balancer Controller Deployment (via Helm) ---

# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.4.0" # Specify a modern version

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.main-eks-cluster.name
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }
  
#   # CRITICAL: Annotate the Service Account with the IRSA Role ARN
#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.lbc_role.arn
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.lbc_policy_attach,
#     aws_eks_cluster.main-eks-cluster
#   ]
# }

