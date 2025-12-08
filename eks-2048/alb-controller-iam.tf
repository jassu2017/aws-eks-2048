# --- 3. IAM Policy for AWS Load Balancer Controller ---

# This policy is required for the controller to manage ALBs, Security Groups, etc.
resource "aws_iam_policy" "alb_controller_policy" {
  name        = "${var.cluster_name}-ALBControllerPolicy"
  description = "IAM Policy for AWS Load Balancer Controller"
  # Loads the policy JSON from the local file
  policy      = file("${path.module}/iam-policy.json") 
}

# --- 4. IAM Role for Service Account (IRSA) ---

# This role is attached to the ALB Controller Kubernetes Service Account.
# It grants the necessary AWS permissions via the OIDC trust relationship.

# Create the service account and role configuration
resource "aws_iam_role" "alb_controller_irsa" {
  name = "${var.cluster_name}-ALBControllerRole"

  # Trust policy for IRSA, allowing the Kubernetes Service Account to assume the role
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
            # Binds the role to a specific namespace and service account name
            # Use the correct, updated output from the EKS module (v21.x)
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