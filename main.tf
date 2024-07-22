provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "k8s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key" {
  content  = tls_private_key.k8s_key.private_key_pem
  filename = "${path.module}/id_rsa"
}

resource "local_file" "ssh_public_key" {
  content  = tls_private_key.k8s_key.public_key_pem
  filename = "${path.module}/id_rsa.pub"
}

resource "aws_key_pair" "k8s_key_pair" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.k8s_key.public_key_openssh
}

resource "aws_security_group" "k8s_sg" {
  name_prefix = "k8s-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks
  }
}

resource "aws_instance" "k8s_master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.k8s_sg.name]
  key_name               = aws_key_pair.k8s_key_pair.key_name

  root_block_device {
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name = "master"
  }
}

resource "aws_instance" "k8s_worker" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.k8s_sg.name]
  key_name               = aws_key_pair.k8s_key_pair.key_name

  root_block_device {
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name = "worker-node${count.index + 1}"
  }
}

output "master_public_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_public_ips" {
  value = [for instance in aws_instance.k8s_worker : instance.public_ip]
}
