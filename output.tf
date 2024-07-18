output "master_node_public_ip" {
  value = aws_instance.master_node.public_ip
}

output "worker_node1_public_ip" {
  value = aws_instance.worker_node1.public_ip
}

output "worker_node2_public_ip" {
  value = aws_instance.worker_node2.public_ip
}
