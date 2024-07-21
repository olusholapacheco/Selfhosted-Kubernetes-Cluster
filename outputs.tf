output "master_public_ip" {
  value = module.ec2_instances.master_public_ip
}

output "worker1_public_ip" {
  value = module.ec2_instances.worker1_public_ip
}

output "worker2_public_ip" {
  value = module.ec2_instances.worker2_public_ip
}

