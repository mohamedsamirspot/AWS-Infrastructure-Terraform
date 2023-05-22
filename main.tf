# Define the AWS provider
provider "aws" {
  shared_config_files      = var.aws_shared_config_files
  shared_credentials_files = var.aws_shared_credentials_files
  profile                  = var.aws_profile
}

# Call the my-VPC module
module "my_main_vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}

# Create the public subnets
module "subnets" {
  source       = "./modules/subnet"
  vpc_id       = module.my_main_vpc.vpc_id
  subnet_cidr  =   {
                      "public_subnet1" = "10.0.0.0/24"
                      "public_subnet2" = "10.0.1.0/24"
                      "private_subnet1" = "10.0.2.0/24"
                      "private_subnet2" = "10.0.3.0/24"
                  }
  subnet_az    = {
                      "public_subnet1" = "us-east-1a"
                      "public_subnet2" = "us-east-1b"
                      "private_subnet1" = "us-east-1c"
                      "private_subnet2" = "us-east-1d"
                  }
}

# Call the internet gateway module
module "internet_gateway" {
  source  = "./modules/internet_gateway"
  vpc_id  = module.my_main_vpc.vpc_id
}

# Call the NAT gateway module and elastic ip
module "nat_gateway" {
  source          = "./modules/nat_gateway"  
  public_subnet_id   = module.subnets.subnet_id["public_subnet1"]
}

# Call the public and private route tables modules
module "public_route_table" {
  source    = "./modules/route_table/public"
  vpc_id    = module.my_main_vpc.vpc_id
  igw_id    = module.internet_gateway.igw_id
}
module "private_route_table" {
  source            = "./modules/route_table/private"
  vpc_id            = module.my_main_vpc.vpc_id
  nat_gateway_id    = module.nat_gateway.nat_id
}


# Associate the route tables with the subnets
module "public_subnet1_association" {
  source         = "./modules/subnet_association"
  subnet_id      = module.subnets.subnet_id["public_subnet1"]
  route_table_id = module.public_route_table.public_route_table_id
}
module "public_subnet2_association" {
  source         = "./modules/subnet_association"
  subnet_id      = module.subnets.subnet_id["public_subnet2"]
  route_table_id = module.public_route_table.public_route_table_id
}
module "private_subnet1_association" {
  source         = "./modules/subnet_association"
  subnet_id      = module.subnets.subnet_id["private_subnet1"]
  route_table_id = module.private_route_table.private_route_table_id
}
module "private_subnet2_association" {
  source         = "./modules/subnet_association"
  subnet_id      = module.subnets.subnet_id["private_subnet2"]
  route_table_id = module.private_route_table.private_route_table_id
}

# Call the security groups module
module "ec2_security_group" {
  security_group_name = "ec2s_security_group"
  source    = "./modules/security_group/ec2_sg"
  vpc_id    = module.my_main_vpc.vpc_id
  ingress_ssh_port = 22
  ingress_http_port = 80
  ingress_protocol = "tcp"
  ingress_cidr_block = "0.0.0.0/0"
  egress_port = 0
  egress_protocol = "-1"
  egress_cidr_block = "0.0.0.0/0"
}
module "alb_security_group" {
  security_group_name = "alb_security_group"
  source    = "./modules/security_group/lb_sg"
  vpc_id    = module.my_main_vpc.vpc_id
  ingress_http_port = 80
  ingress_protocol = "tcp"
  ingress_cidr_block = "0.0.0.0/0"
  egress_port = 0
  egress_protocol = "-1"
  egress_cidr_block = "0.0.0.0/0"
}

# datasource to get the ubuntu ami id
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
# expect this image id ami-053b0d53c279acc90
output "image_id" {
  value = data.aws_ami.ubuntu.id
}
# Call the instances modules
module "public_ec2_1" {
  source              = "./modules/ec2/public"
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id          = module.subnets.subnet_id["public_subnet1"]
  security_group_ids   = [module.ec2_security_group.ec2_sg_id]
  key_name            = "my-keypair"
  ec2_name = "Public nginx 1"
  ec2_username = "ubuntu"
  inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo echo 'Hello from nginx 1' | sudo tee /var/www/html/index.html",
      "sudo awk 'BEGIN{p=0} $0 ~ /^}$/ && p==1 {p=0} p==1 {next} $0 ~ /^server \\{$/ {print; print \"\\tlisten 80 default_server;\"; print \"\\tlisten [::]:80 default_server;\"; print \"\\troot /var/www/html;\"; print \"\\tindex index.html index.htm index.nginx-debian.html;\"; print \"\\tserver_name _;\"; print \"\"; print \"\\tlocation / {\"; print \"\\t\\tproxy_pass http://${aws_lb.private_lb.dns_name}:80;\"; print \"\\t\\tproxy_set_header Host $host;\"; print \"\\t\\tproxy_set_header X-Real-IP $remote_addr;\"; print \"\\t}\"; p=1; next} 1' /etc/nginx/sites-available/default > /tmp/nginx.tmp && sudo mv /tmp/nginx.tmp /etc/nginx/sites-available/default",
      "sudo systemctl restart nginx"
    ]
}
module "public_ec2_2" {
  source              = "./modules/ec2/public"
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id          = module.subnets.subnet_id["public_subnet2"]
  security_group_ids   = [module.ec2_security_group.ec2_sg_id]
  key_name            = "my-keypair"
  ec2_name = "Public nginx 2"
  ec2_username = "ubuntu"
  inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo echo 'Hello from nginx 2' | sudo tee /var/www/html/index.html",
      "sudo awk 'BEGIN{p=0} $0 ~ /^}$/ && p==1 {p=0} p==1 {next} $0 ~ /^server \\{$/ {print; print \"\\tlisten 80 default_server;\"; print \"\\tlisten [::]:80 default_server;\"; print \"\\troot /var/www/html;\"; print \"\\tindex index.html index.htm index.nginx-debian.html;\"; print \"\\tserver_name _;\"; print \"\"; print \"\\tlocation / {\"; print \"\\t\\tproxy_pass http://${aws_lb.private_lb.dns_name}:80;\"; print \"\\t\\tproxy_set_header Host $host;\"; print \"\\t\\tproxy_set_header X-Real-IP $remote_addr;\"; print \"\\t}\"; p=1; next} 1' /etc/nginx/sites-available/default > /tmp/nginx.tmp && sudo mv /tmp/nginx.tmp /etc/nginx/sites-available/default",
      "sudo systemctl restart nginx"
    ]
}
module "private_ec2_1" {
  source              = "./modules/ec2/private"
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id          = module.subnets.subnet_id["private_subnet1"]
  security_group_ids   = [module.ec2_security_group.ec2_sg_id]
  key_name            = "my-keypair"
  ec2_name = "Public apache 1"
  ec2_username = "ubuntu"
  ec2_user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    service apache2 start
    echo "<h1>Hello from Apache 1</h1>" | tee /var/www/html/index.html
  EOF
}
module "private_ec2_2" {
  source              = "./modules/ec2/private"
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id          = module.subnets.subnet_id["private_subnet2"]
  security_group_ids   = [module.ec2_security_group.ec2_sg_id]
  key_name            = "my-keypair"
  ec2_name = "Public apache 2"
  ec2_username = "ubuntu"
  ec2_user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    service apache2 start
    echo "<h1>Hello from Apache 2</h1>" | tee /var/www/html/index.html
  EOF
}

# Create the public Application Load Balancer
resource "aws_lb" "public_lb" {
  name               = "public-lb"
  load_balancer_type = "application"
  subnets            = [module.subnets.subnet_id["public_subnet1"], module.subnets.subnet_id["public_subnet2"]]
  security_groups    = [module.alb_security_group.lb_sg_id]
}

# Create the target group for the public subnets
resource "aws_lb_target_group" "public_target_group" {
  name     = "public-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.my_main_vpc.vpc_id

  target_type = "instance"
}

# Attach public-ec2_1 to the target group
resource "aws_lb_target_group_attachment" "public_ec2_1_attachment" {
  target_group_arn = aws_lb_target_group.public_target_group.arn
  target_id        = module.public_ec2_1.public_ec2_id
  port             = 80
}

# Attach public-ec2_2 to the target group
resource "aws_lb_target_group_attachment" "public_ec2_2_attachment" {
  target_group_arn = aws_lb_target_group.public_target_group.arn
  target_id        = module.public_ec2_2.public_ec2_id
  port             = 80
}

# Add listener to the public load balancer
resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.public_target_group.arn
    type             = "forward"
  }
}

# Create the private Application Load Balancer
resource "aws_lb" "private_lb" {
  name               = "private-lb"
  load_balancer_type = "application"
  subnets            = [module.subnets.subnet_id["private_subnet1"], module.subnets.subnet_id["private_subnet2"]]
  security_groups    = [module.alb_security_group.lb_sg_id]
  internal           = true
}

# Create the target group for the private subnets
resource "aws_lb_target_group" "private_target_group" {
  name     = "private-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.my_main_vpc.vpc_id

  target_type = "instance"
}

# Attach private-ec2_1 to the target group
resource "aws_lb_target_group_attachment" "private_ec2_1_attachment" {
  target_group_arn = aws_lb_target_group.private_target_group.arn
  target_id        = module.private_ec2_1.private_ec2_id
  port             = 80
}

# Attach private-ec2_2 to the target group
resource "aws_lb_target_group_attachment" "private_ec2_2_attachment" {
  target_group_arn = aws_lb_target_group.private_target_group.arn
  target_id        = module.private_ec2_2.private_ec2_id
  port             = 80
}

# Add listener to the private load balancer
resource "aws_lb_listener" "private_listener" {
  load_balancer_arn = aws_lb.private_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.private_target_group.arn
    type             = "forward"
  }
}