output "public_ec2_id" {
  description = "The ID of the public ec2"
  value       = aws_instance.public_instance.id
}