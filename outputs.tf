output "master_public_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_public_ips" {
  value = [for instance in aws_instance.k8s_worker : instance.public_ip]
}
