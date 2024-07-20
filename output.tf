output "master_public_ip" {
  value = module.ec2_instances.master_public_ip
}

output "worker_public_ips" {
  value = module.ec2_instances.worker_public_ips
}
