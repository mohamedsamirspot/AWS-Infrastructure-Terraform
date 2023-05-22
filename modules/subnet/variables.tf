variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "subnet_cidr" {
  type        = map(string)
  description = "CIDR block for the subnet"
}

variable "subnet_az" {
  type        = map(string)
  description = "Availability Zone for the subnet"
}