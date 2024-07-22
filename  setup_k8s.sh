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
  kubeadm init --pod-network-cidr=10.244.0.0/16
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config

  # Install a Pod network add-on (Flannel)
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

  # Generate join command
  kubeadm token create --print-join-command > /root/join_command.sh
else
  # Join worker nodes to the cluster
  bash /root/join_command.sh
fi
