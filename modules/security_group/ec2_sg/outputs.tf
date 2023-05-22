output "ec2_sg_id" {
  description = "The ID of the secrutiy group of the ec2"
  value       = aws_security_group.ec2_sg.id
}