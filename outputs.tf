output "master_node_public_ip" {
  value = module.ec2_instances.master_node_public_ip
}

output "worker_node1_public_ip" {
  value = module.ec2_instances.worker_node1_public_ip
}

output "worker_node2_public_ip" {
  value = module.ec2_instances.worker_node2_public_ip
}
