resource "aws_security_group" "ec2_sg" {
  name        = var.security_group_name
  vpc_id            = var.vpc_id
  # Define ingress and egress rules as per your requirements
  ingress {
    from_port   = var.ingress_ssh_port
    to_port     = var.ingress_ssh_port
    protocol    = var.ingress_protocol
    cidr_blocks = [var.ingress_cidr_block]
  }
  ingress {
    from_port   = var.ingress_http_port
    to_port     = var.ingress_http_port
    protocol    = var.ingress_protocol
    cidr_blocks = [var.ingress_cidr_block]
  }

  egress {
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = var.egress_protocol
    cidr_blocks = [var.egress_cidr_block]
  }
}