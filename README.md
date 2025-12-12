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


