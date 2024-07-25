#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

set -e # Exit immediately if any command returns a non-zero status.

# Install necessary dependencies
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Configure persistent loading of modules
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Load modules at runtime
sudo modprobe overlay
sudo modprobe br_netfilter

# Update Iptables Settings
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Apply kernel settings without reboot
sudo sysctl --system

# Add Docker repository GPG key to trusted keys
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository to Ubuntu package sources
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install containerd
sudo apt-get update && sudo apt-get install -y containerd.io

# Configure containerd for Systemd Cgroup Management
sudo mkdir -p /etc/containerd
sudo containerd config default >/etc/containerd/config.toml
sudo sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml

# Reload daemon, restart, enable, and check containerd service status
sudo systemctl daemon-reload
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status containerd

# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Install kubeadm, kubelet and kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize Kubernetes on master
if hostname | grep -q "master"; then
  sudo kubeadm init --pod-network-cidr=10.244.0.0/16
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  # Install a Pod network add-on (Flannel)
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

  # Generate join command
  sudo kubeadm token create --print-join-command > /root/join_command.sh
else
  # Join worker nodes to the cluster
  sudo bash /root/join_command.sh
fi
