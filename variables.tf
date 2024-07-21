variable "master_instance_type" {
  default = "t3.medium"
}

variable "worker_instance_type" {
  default = "t3.medium"
}

variable "ami_id" {
  default = "ami-003932de22c285676"
}

variable "key_name" {
  description = "SSH key pair name"
}

variable "subnet_id" {
  description = "Subnet ID"
}

variable "security_group_ids" {
  description = "Security group IDs"
}
