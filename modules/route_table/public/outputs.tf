output "public_route_table_id" {
  description = "The ID of the public route"
  value       = aws_route_table.public_route_table.id
}