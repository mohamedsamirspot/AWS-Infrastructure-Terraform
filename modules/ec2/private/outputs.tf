output "private_ec2_id" {
  description = "The ID of the private ec2"
  value       = aws_instance.private_instance.id
}