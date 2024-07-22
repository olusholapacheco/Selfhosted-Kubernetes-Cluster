variable "aws_region" {
  description = "The AWS region to deploy the infrastructure in"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "The type of instance to deploy"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "The AMI ID to use for the instances"
  type        = string
  default     = "ami-003932de22c285676"
}

variable "vpc_id" {
  description = "The VPC ID where the instances will be deployed"
  type        = string
  default     = "vpc-027b20294366b2905"
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for the instances"
  type        = string
  default     = "generated-key"
}

variable "cidr_blocks" {
  description = "The list of CIDR blocks to allow access to the instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
