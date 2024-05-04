# Launching Private Backend Application Behind NLB
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_launch_template" "private_app_template" {
  name_prefix   = "backend-private-ec2"
  image_id      = var.backend_ami_id != null ? var.backend_ami_id : data.aws_ami.amazon_linux_2.id

  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile {
    name = var.app_iam_profile
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "private_backend_asg" {
  launch_template {
    id      = aws_launch_template.private_app_template.id
    version = "$Latest"
  }

  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids

  # Register instances with the target group
  target_group_arns    = [aws_lb_target_group.backend_tg.arn]

  tag {
    key                 = "Name"
    value               = "Private-Backend-App"
    propagate_at_launch = true
  }
}

resource "aws_lb" "private_app_nlb" {
  name               = var.nlb_name
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "${var.nlb_name}-tg-group"
  port     = var.nlb_tg_port
  protocol = var.nlb_tg_protocol
  vpc_id   = var.vpc_id

  health_check {
    protocol = var.nlb_tg_protocol
    port     = var.nlb_tg_port
    interval = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.private_app_nlb.arn
  port              = var.nlb_listener_port
  protocol          = var.nlb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}
