provider "aws" {
  region = "us-east-2"
}

# Data sources for default VPC and subnet
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Security Group with initial broad SSH access
resource "aws_security_group" "k8s_sg" {
  name_prefix = "k8s-sg-"
  description = "Allow specific inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# SSH key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${local_file.ssh_public_key.filename}")
}

module "ec2_instances" {
  source               = "./ec2_instance_module"
  master_instance_type = var.master_instance_type
  worker_instance_type = var.worker_instance_type
  ami_id               = var.ami_id
  key_name             = aws_key_pair.deployer.key_name
  subnet_id            = data.aws_subnets.default.ids[0]
  security_group_ids   = [aws_security_group.k8s_sg.id]
}

output "master_public_ip" {
  value = module.ec2_instances.master_public_ip
}

output "worker1_public_ip" {
  value = module.ec2_instances.worker1_public_ip
}

output "worker2_public_ip" {
  value = module.ec2_instances.worker2_public_ip
}

