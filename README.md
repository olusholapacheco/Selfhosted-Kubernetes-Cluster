# Selfhosted-Kubernetes-Cluster


Deploying selfhosted Kubernetes Cluster using Kubeadm, AWS EC2s, Terraform and Github Actions. (17/7/2024)

# Requirements 
Ubuntu server 
- Master node  -1
- Worker node -2
- Docker 
- Kubernetes packages (Kubelet, kubeadm, Kubectl)
- Container Runtime - containerd
- Container Network Interface - Flannel


# terraform.tfvars.changes 
This is added as a reminder that terraform.tfvars though mostly added to .gitignore, changes in this file can be used to override the configurations to make quick deployments without needing to rework the whole terraform file all over again

# statefiles and storing concurrency 

This is a simple project, even though in production environments, S3 buckets are created to store state file and Dynamodb to handle concurrency. We are not creating this here to save on aws costs.


# Container Network Interface

In this case I choose to use Flannel for its simplicity, even though Calico is a best choice to simulate production level CNI. Sticking to Flannel for the ease of set up


