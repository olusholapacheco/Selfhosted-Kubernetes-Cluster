output "master_public_ip" {
  value = aws_instance.master_node.public_ip
}

output "worker1_public_ip" {
  value = aws_instance.worker_node1.public_ip
}

output "worker2_public_ip" {
  value = aws_instance.worker_node2.public_ip
}
