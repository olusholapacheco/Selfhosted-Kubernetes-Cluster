resource "local_file" "ssh_public_key" {
  content  = tls_private_key.deployer.public_key_openssh
  filename = "${path.module}/deployer-key.pub"
}

resource "local_file" "ssh_private_key" {
  content  = tls_private_key.deployer.private_key_pem
  filename = "${path.module}/deployer-key.pem"
}

resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
