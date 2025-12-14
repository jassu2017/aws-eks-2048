# aws-eks-2048
The demo for aws eks 2048 game 

separate the Kubernetes resource deployment (like Helm charts) from the EKS cluster creation into a two-stage process.

1st apply:
------------

vpc module, eks module, cluster creation , fargate iam,profile creation

2nd apply:
-------------

k8s resources like aws alb controller, helm charts, oidc connection, iam roles , irsa are created.

Note: before 2nd apply,

set the aws configure profile:

# Set your AWS Access Key ID
export AWS_ACCESS_KEY_ID="AKI"

# Set your AWS Secret Access Key (Use caution with history/logs)
export AWS_SECRET_ACCESS_KEY="Xq"

# Set the region where the EKS cluster was created
export AWS_REGION="ap-south-1"

Q:Why it is necessary to attach OIDC provider to the eks cluster?
A: because, IAM roles can be used inside K8s cluster.

Since AWS Load Balancer Controller needs permission to manage AWS Load balancer, need to create IAM policy and associate with K8s Service account.
After creation of the IAM role (attaching the AWS LBC policy ), LBC can make call to AWS api.

IAM Service account is created in K8s, so that AWS LBC can manager LB on behalf of k8s.




