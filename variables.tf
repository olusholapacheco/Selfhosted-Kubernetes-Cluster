variable "master_instance_type" {
  description = "The type of EC2 instance for the master node"
  type        = string
}

variable "worker_instance_type" {
  description = "The type of EC2 instance for the worker nodes"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the instances"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the instances will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to assign to the instances"
  type        = list(string)
}
