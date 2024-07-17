provider "aws" {
  region = "us-east-2"  
}

resource "aws_instance" "master_node" {
  ami           = "ami-003932de22c285676"  
  instance_type = "t3.medium"
  tags = {
    Name = "master-node"
  }
}

resource "aws_instance" "worker_node1" {
  ami           = "ami-003932de22c285676"  
  instance_type = "t3.medium"
  tags = {
    Name = "worker-node1"
  }
}

resource "aws_instance" "worker_node2" {
  ami           = "ami-003932de22c285676"  
  instance_type = "t3.medium"
  tags = {
    Name = "worker-node2"
  }
}





