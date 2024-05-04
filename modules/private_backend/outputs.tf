output "launch_template_id" {
  value       = aws_launch_template.private_app_template.id
  description = "ID of the launch template used by the ASG"
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.private_backend_asg.name
  description = "Name of the Auto Scaling Group"
}

output "application_load_balancer_arn" {
  value       = aws_lb.private_app_nlb.arn
  description = "ARN of the Network Load Balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.backend_tg.arn
  description = "ARN of the target group associated with the ALB"
}

output "load_balancer_listener_arn" {
  value       = aws_lb_listener.backend_listener.arn
  description = "ARN of the listener on the Application Load Balancer"
}

output "nlb_dns_name" {
  value       = aws_lb.private_app_nlb.dns_name
  description = "DNS name of the Network Load Balancer"
}
