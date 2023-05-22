output "nat_id" {
  description = "The ID of the nat gateway"
  value       = aws_nat_gateway.nat_gateway.id
}