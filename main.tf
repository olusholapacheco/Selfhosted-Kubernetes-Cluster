provider "aws" {
  region = "us-east-2"
}

# Data sources for default VPC and subnet
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Security Group with initial broad SSH access, SSH access restricted to IP address will be updated once EC2 is deployed 
resource "aws_security_group" "k8s_sg" {
  name_prefix = "k8s-sg-"
  description = "Allow specific inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere is not best practice
    description = "SSH access"
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubernetes API server"
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubelet API"
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort Services"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s_sg"
  }
}

# Create Master Node Instance
resource "aws_instance" "master_node" {
  ami           = "ami-003932de22c285676"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = data.aws_subnet_ids.default.ids[0]
  security_groups = [aws_security_group.k8s_sg.name]

  tags = {
    Name = "master-node"
  }

  provisioner "file" {
    source      = "${local_file.ssh_public_key.filename}"
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
    private_key = file("${local_file.ssh_private_key.filename}")
    host        = self.public_ip
  }
}

# Fetch Join Command
resource "null_resource" "fetch_join_command" {
  depends_on = [aws_instance.master_node]

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ${local_file.ssh_private_key.filename} root@${aws_instance.master_node.public_ip}:/root/joincommand.sh ./joincommand.sh"
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("${local_file.ssh_private_key.filename}")
    host        = aws_instance.master_node.public_ip
  }
}

# Create Worker Node Instances
resource "aws_instance" "worker_node1" {
  ami           = "ami-003932de22c285676"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = data.aws_subnet_ids.default.ids[0]
  security_groups = [aws_security_group.k8s_sg.name]

  tags = {
    Name = "worker-node1"
  }

  provisioner "file" {
    source      = "${local_file.ssh_public_key.filename}"
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
      "sleep 60",  # Ensure master node setup is complete
      "JOIN_COMMAND=$(cat /root/joincommand.sh)",
      "eval $JOIN_COMMAND"
    ]
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("${local_file.ssh_private_key.filename}")
    host        = self.public_ip
  }

  depends_on = [null_resource.fetch_join_command]
}

resource "aws_instance" "worker_node2" {
  ami           = "ami-003932de22c285676"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = data.aws_subnet_ids.default.ids[0]
  security_groups = [aws_security_group.k8s_sg.name]

  tags = {
    Name = "worker-node2"
  }

  provisioner "file" {
    source      = "${local_file.ssh_public_key.filename}"
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
      "sleep 60",  # This gives a bit of time to ensure the master node setup is complete
      "JOIN_COMMAND=$(cat /root/joincommand.sh)",
      "eval $JOIN_COMMAND"
    ]
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("${local_file.ssh_private_key.filename}")
    host        = self.public_ip
  }

  depends_on = [null_resource.fetch_join_command]
}
