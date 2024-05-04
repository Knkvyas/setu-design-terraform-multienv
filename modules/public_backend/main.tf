# Launching Backend Application Behind ELB
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

resource "aws_launch_template" "public_app_template" {
  name_prefix   = "backend-public-ec2"
  image_id      = var.frontend_ami_id != null ? var.frontend_ami_id : data.aws_ami.amazon_linux_2.id

  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile {
    name = var.app_iam_profile
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_public_asg" {
  launch_template {
    id      = aws_launch_template.public_app_template.id
    version = "$Latest"
  }

  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids

  # Register instances with the target group
  target_group_arns    = [aws_lb_target_group.public_app_tg.arn]

  tag {
    key                 = "Name"
    value               = "Public-Backend-App"
    propagate_at_launch = true
  }
}

resource "aws_lb" "public_app_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_sg_id
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "public_app_tg" {
  name     = "${var.alb_name}-tg-group"
  port     = var.alb_tg_port
  protocol = var.alb_tg_protocol
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = var.alb_tg_protocol
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.public_app_alb.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_app_tg.arn
  }
}

