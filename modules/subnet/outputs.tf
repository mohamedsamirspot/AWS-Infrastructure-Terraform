output "subnet_id" {
  description = "The IDs of the subnets"
  value       = { for key, subnet in aws_subnet.subnet : key => subnet.id }
}