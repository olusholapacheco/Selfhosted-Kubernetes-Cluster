variable "vpc_id" {
  type        = string
  description = "The VPC ID to launch instances in"
  default     = "vpc-027b20294366b2905"
}

variable "master_instance_type" {
  type        = string
  description = "EC2 instance type for the master node"
  default     = "t3.medium"
}

variable "worker_instance_type" {
  type        = string
  description = "EC2 instance type for the worker nodes"
  default     = "t3.medium"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instances"
  default     = "ami-003932de22c285676"
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
  default     = "${path.module}/id_rsa.pub"
}

variable "private_key_path" {
  type        = string
  description = "Path to the SSH private key"
  default     = "${path.module}/id_rsa"
}