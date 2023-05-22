output "lb_sg_id" {
  description = "The ID of the secrutiy group of the load balancer"
  value       = aws_security_group.lb_sg.id
}