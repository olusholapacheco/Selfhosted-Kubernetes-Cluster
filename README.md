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

In this case I choose to use Flannel for its simplicity, even though Calico is a best choice to simulate production level CNI. Sticking to Flannel for the ease of set up. Using Calico, the shell file would look like this 

#!/bin/bash

# Install Docker
apt-get update
apt-get install -y docker.io

# Install kubeadm, kubelet and kubectl
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Initialize Kubernetes on master
if hostname | grep -q "master"; then
  kubeadm init --pod-network-cidr=192.168.0.0/16
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config

  # Install a Pod network add-on (Calico)
  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

  # Generate join command
  kubeadm token create --print-join-command > /root/join_command.sh
else
  # Join worker nodes to the cluster
  bash /root/join_command.sh
fi



