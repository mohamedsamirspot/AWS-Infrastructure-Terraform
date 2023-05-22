resource "aws_instance" "private_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = var.security_group_ids
  key_name            = var.key_name
  tags = {
    Name = var.ec2_name
  }
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> ./all-ips.txt"
  }
  user_data = var.ec2_user_data
}
