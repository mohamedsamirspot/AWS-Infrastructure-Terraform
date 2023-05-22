variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "security_group_name" {
  type        = string
  description = "Name of the security group"
}

variable "ingress_ssh_port" {
  type        = number
  description = "Ingress port number"
}

variable "ingress_http_port" {
  type        = number
  description = "Ingress port number"
}

variable "ingress_protocol" {
  type        = string
  description = "Ingress protocol"
}

variable "ingress_cidr_block" {
  type        = string
  description = "CIDR block for ingress"
}

variable "egress_port" {
  type        = number
  description = "Egress port number"
}

variable "egress_protocol" {
  type        = string
  description = "Egress protocol"
}

variable "egress_cidr_block" {
  type        = string
  description = "CIDR block for egress"
}
