output "launch_template_id" {
  value       = aws_launch_template.public_app_template.id
  description = "ID of the launch template used by the ASG"
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.app_public_asg.name
  description = "Name of the Auto Scaling Group"
}

output "application_load_balancer_arn" {
  value       = aws_lb.public_app_alb.arn
  description = "ARN of the Application Load Balancer"
}
output "application_load_balancer_dns" {
  value       = aws_lb.public_app_alb.dns_name
  description = "DNS Name of the Application Load Balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.public_app_tg.arn
  description = "ARN of the target group associated with the ALB"
}

output "load_balancer_listener_arn" {
  value       = aws_lb_listener.front_end.arn
  description = "ARN of the listener on the Application Load Balancer"
}
