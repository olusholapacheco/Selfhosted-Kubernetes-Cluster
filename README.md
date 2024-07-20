# Selfhosted-Kubernetes-Cluster


Deploying selfhosted Kubernetes Cluster using Kubeadm, AWS EC2s, Terraform and Github Actions. (17/7/2024)

# Requirements 
Ubuntu server 
- Master node  -1
- Worker node -2
- Docker 
- Kubernetes packages (Kubelet, kubeadm, Kubectl)
- Container Runtime - containerd
- Container Network Interface - Calico


# Why do we have two main.tf files, one as root and the other under the EC2 module?
The separation into two main.tf files is to modularize the configuration. The root main.tf handles the overall infrastructure setup and references the ec2_instance_module, which contains its own main.tf for specific EC2 instance configurations. This modular approach improves organization, reusability, and maintainability of the Terraform code.

