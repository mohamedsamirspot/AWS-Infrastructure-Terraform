variable "ami" {
  type        = string
  description = "AMI ID for the public instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the public instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the public instance"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group ID for the public instance"
}

variable "key_name" {
  type        = string
  description = "the name of the key pair"
}

variable "ec2_name" {
  type        = string
  description = "the name of the ec2"
}

variable "ec2_username" {
  type        = string
  description = "the name of the ec2 user"
}

variable "inline" {
  type        = list(string)
  description = "the userdata that i want for the remote provisioner"
}
