variable "vpc_id" {
  type        = string
  description = "The VPC ID to launch instances in"
}

variable "master_instance_type" {
  type        = string
  description = "EC2 instance type for the master node"
}

variable "worker_instance_type" {
  type        = string
  description = "EC2 instance type for the worker nodes"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instances"
}

variable "key_name" {
  type        = string
  description = "The name of the SSH key pair"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID to launch instances in"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to associate with"
}

variable "public_key_path" {
  type        = string
  description = "Path to the SSH public key"
}

variable "private_key_path" {
  type        = string
  description = "Path to the SSH private key"
}

resource "aws_instance" "master_node" {
  ami                    = var.ami_id
  instance_type          = var.master_instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  security_group_ids     = var.security_group_ids
  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "master-node"
  }

  provisioner "file" {
    source      = var.public_key_path
    destination = "/root/.ssh/authorized_keys"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "apt-get update",
      "apt-get install -y docker-ce",
      "systemctl enable docker",
      "systemctl start docker",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -",
      "apt-add-repository \"deb http://apt.kubernetes.io/ kubernetes-xenial main\"",
      "apt-get update",
      "apt-get install -y kubelet kubeadm kubectl",
      "kubeadm init --pod-network-cidr=10.244.0.0/16",
      "mkdir -p /root/.kube",
      "cp -i /etc/kubernetes/admin.conf /root/.kube/config",
      "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml",
      "kubeadm token create --print-join-command > /root/joincommand.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }
}

resource "null_resource" "fetch_join_command" {
  depends_on = [aws_instance.master_node]

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ${var.private_key_path} root@${aws_instance.master_node.public_ip}:/root/joincommand.sh ./joincommand.sh"
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_path)
    host        = aws_instance.master_node.public_ip
  }
}

resource "aws_instance" "worker_node1" {
  ami                    = var.ami_id
  instance_type          = var.worker_instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  security_group_ids     = var.security_group_ids
  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "worker-node1"
  }

  provisioner "file" {
    source      = var.public_key_path
    destination = "/root/.ssh/authorized_keys"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "apt-get update",
      "apt-get install -y docker-ce",
      "systemctl enable docker",
      "systemctl start docker",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -",
      "apt-add-repository \"deb http://apt.kubernetes.io/ kubernetes-xenial main\"",
      "apt-get update",
      "apt-get install -y kubelet kubeadm kubectl",
      "sleep 60",
      "JOIN_COMMAND=$(cat /root/joincommand.sh)",
      "eval $JOIN_COMMAND"
    ]
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  depends_on = [null_resource.fetch_join_command]
}

resource "aws_instance" "worker_node2" {
  ami                    = var.ami_id
  instance_type          = var.worker_instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  security_group_ids     = var.security_group_ids
  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "worker-node2"
  }

  provisioner "file" {
    source      = var.public_key_path
    destination = "/root/.ssh/authorized_keys"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "apt-get update",
      "apt-get install -y docker-ce",
      "systemctl enable docker",
      "systemctl start docker",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -",
      "apt-add-repository \"deb http://apt.kubernetes.io/ kubernetes-xenial main\"",
      "apt-get update",
      "apt-get install -y kubelet kubeadm kubectl",
      "sleep 60",
      "JOIN_COMMAND=$(cat /root/joincommand.sh)",
      "eval $JOIN_COMMAND"
    ]
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  depends_on = [null_resource.fetch_join_command]
}
