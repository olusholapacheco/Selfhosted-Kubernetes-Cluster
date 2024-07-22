provider "aws" {
  region = "us-east-2"
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_security_group" "k8s_sg" {
  name_prefix = "k8s-sg-"
  description = "Allow specific inbound traffic"
  vpc_id      = var.vpc_id

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

module "ec2_instances" {
  source              = "./ec2_instance_module"
  vpc_id              = var.vpc_id
  master_instance_type = var.master_instance_type
  worker_instance_type = var.worker_instance_type
  ami_id              = var.ami_id
  key_name            = var.key_name
  subnet_id           = data.aws_subnets.default.ids[0]
  security_group_ids  = [aws_security_group.k8s_sg.id]
  public_key_path     = var.public_key_path
  private_key_path    = var.private_key_path
}
