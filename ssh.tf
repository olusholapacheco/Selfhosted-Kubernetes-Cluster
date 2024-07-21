resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = file(var.public_key_path)
}

resource "local_file" "ssh_private_key" {
  content  = file(var.private_key_path)
  filename = "${path.module}/deployer.pem"
}

resource "local_file" "ssh_public_key" {
  content  = file(var.public_key_path)
  filename = "${path.module}/deployer.pub"
}
