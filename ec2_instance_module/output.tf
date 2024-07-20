output "master_public_ip" {
  value = aws_instance.master_node.public_ip
}

output "worker_public_ips" {
  value = [aws_instance.worker_node1.public_ip, aws_instance.worker_node2.public_ip]
}
