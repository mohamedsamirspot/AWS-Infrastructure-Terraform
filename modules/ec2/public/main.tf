resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = var.security_group_ids
  key_name            = var.key_name
  associate_public_ip_address = true
  tags = {
    Name = var.ec2_name
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> ./all-ips.txt"
  }
    connection {
    type = "ssh"
    host = self.public_ip
    user = var.ec2_username
    private_key = file("./my-keypair.pem")
    timeout = "4m"
  }
  provisioner "remote-exec" {
    inline = var.inline
  }
}
