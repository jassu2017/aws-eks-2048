
## alb-controller-iam.tf

# --- 1. Required Input Variable for Dashboard Access ---
variable "dashboard_principal_arn" {
  description = "The ARN of the IAM User/Role that needs access to the EKS Kubernetes API (e.g., for dashboard or kubectl)."
  type        = string
  # NOTE: Replace this default with your actual IAM Principal ARN!
  default     = "arn:aws:iam::082088055283:user/MyEKSAdmin" 
}

# --- 2. OIDC Provider Reference (Already in your EKS module) ---
# Assuming you reference the OIDC ARN and URL from your EKS module:
# module.eks.oidc_provider_arn  and module.eks.oidc_provider
# If you are not using a module, you would define aws_iam_openid_connect_provider here.

# --- 3. IAM Policy for AWS Load Balancer Controller ---
resource "aws_iam_policy" "alb_controller_policy" {
  name        = "${var.cluster_name}-ALBControllerPolicy"
  description = "IAM Policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam-policy.json") 
}

# --- 4. IAM Role for Service Account (IRSA) ---
resource "aws_iam_role" "alb_controller_irsa" {
  name = "${var.cluster_name}-ALBControllerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:aud": "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# Attach the policy to the IRSA role
resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller_irsa.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

# --- 5. EKS Access Entry for Human Access (The Fix for the dashboard warning) ---

# This resource maps the IAM principal (your user/role) to Kubernetes RBAC.
resource "aws_eks_access_entry" "dashboard_admin_access" {
  # Must use the cluster name
  cluster_name  = var.cluster_name 
  
  # The IAM User or Role ARN that needs access
  principal_arn = var.dashboard_principal_arn 
  
  # You can optionally set a custom username or Kubernetes groups here:
  # kubernetes_groups = ["system:masters"] # If you prefer to use the groups method
  
  # Use an Access Policy Association to grant permissions easily
  # This uses the AWS-managed policy for full cluster admin access
  # access_policy_association {
  #   # The policy ARN granting Kubernetes permissions
  #   policy_arn = "arn:aws:eks:${var.aws_region}::aws:cluster-access-policy/EKS-AccessPolicy-ClusterAdmin" 
    
  #   access_scope {
  #     type = "CLUSTER" # Grants access across the entire cluster
  #   }
  # }
}

resource "aws_eks_access_policy_association" "example" {
  cluster_name  = var.cluster_name 
  policy_arn = "arn:aws:eks:${var.aws_region}::aws:cluster-access-policy/EKS-AccessPolicy-ClusterAdmin" 
  principal_arn = var.dashboard_principal_arn

  access_scope {
    type       = "CLUSTER"
    #namespaces = ["example-namespace"]
  }
}



# # --- 3. IAM Policy for AWS Load Balancer Controller ---

# # This policy is required for the controller to manage ALBs, Security Groups, etc.
# resource "aws_iam_policy" "alb_controller_policy" {
#   name        = "${var.cluster_name}-ALBControllerPolicy"
#   description = "IAM Policy for AWS Load Balancer Controller"
#   # Loads the policy JSON from the local file
#   policy      = file("${path.module}/iam-policy.json") 
# }

# # --- 4. IAM Role for Service Account (IRSA) ---

# # This role is attached to the ALB Controller Kubernetes Service Account.
# # It grants the necessary AWS permissions via the OIDC trust relationship.

# # Create the service account and role configuration
# resource "aws_iam_role" "alb_controller_irsa" {
#   name = "${var.cluster_name}-ALBControllerRole"

#   # Trust policy for IRSA, allowing the Kubernetes Service Account to assume the role
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = module.eks.oidc_provider_arn
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             # Binds the role to a specific namespace and service account name
#             # Use the correct, updated output from the EKS module (v21.x)
#             "${module.eks.oidc_provider}:aud": "sts.amazonaws.com",
#             "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
#           }
#         }
#       }
#     ]
#   })
# }

# # Attach the policy to the IRSA role
# resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
#   role       = aws_iam_role.alb_controller_irsa.name
#   policy_arn = aws_iam_policy.alb_controller_policy.arn
# }