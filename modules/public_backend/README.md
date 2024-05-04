# Terraform Module for Public Backend Application Deployment

## Module Overview

This Terraform module automates the deployment of a backend application on AWS, utilizing an Application Load Balancer (ALB) to manage incoming traffic. The setup includes an Amazon Machine Image (AMI) lookup, EC2 instances managed by an Auto Scaling Group (ASG), and the necessary networking configurations.

## Resources

### Data Source: `aws_ami`
- **Purpose**: Retrieves the latest Amazon Linux 2 AMI that matches the specified criteria, ensuring the EC2 instances are launched with up-to-date software.
- **Filters**:
  - AMI name pattern: `amzn2-ami-hvm-*-x86_64-ebs`
  - Owner: Amazon

### Resource: `aws_launch_template`
- **Purpose**: Defines the configuration template for launching public-facing EC2 instances within the Auto Scaling Group.
- **Features**:
  - Dynamically selects an AMI based on input or defaults to the latest Amazon Linux 2 AMI.
  - Configures instance type and security settings.

### Resource: `aws_autoscaling_group`
- **Purpose**: Manages the scaling and health of EC2 instances, ensuring that the application maintains the desired capacity and instances are spread across the available subnets.
- **Key Configurations**:
  - Minimum and maximum sizes
  - Desired capacity
  - Association with target groups for load balancing

### Resource: `aws_lb`
- **Purpose**: Provisions an Application Load Balancer to distribute incoming application traffic across multiple instances efficiently.
- **Configuration**:
  - Operates externally (not internal to VPC).
  - Utilizes specified security groups and subnets.

### Resource: `aws_lb_target_group`
- **Purpose**: Defines how traffic should be routed to the connected instances, including health check configurations to ensure traffic is only routed to healthy instances.
- **Health Check Settings**:
  - Protocol, path, and port settings
  - Health evaluation thresholds and intervals

### Resource: `aws_lb_listener`
- **Purpose**: Listens on a specific port and protocol, directing traffic to a target group based on predefined rules.
- **Action**:
  - Forwards traffic to the target group.

## Usage

To deploy this module, ensure you have defined all required variables in your Terraform configuration. Here is an reference how to use this module:

```hcl
module "public_backend_app" {
  source                = "../../modules/public_backend"
  alb_name              = var.alb_name
  frontend_ami_id       = var.public_app_ami
  instance_type         = var.instance_type
  app_iam_profile       = module.access_manager.iam_instance_profile
  security_group_ids    = [module.network_module.public_app_security_group_id]
  vpc_id                = module.network_module.vpc_id
  subnet_ids            = module.network_module.app_subnet_ids
  alb_listener_port     = var.alb_listener_port
  alb_listener_protocol = var.alb_listener_protocol
  alb_tg_port           = var.alb_tg_port
  alb_tg_protocol       = var.alb_tg_protocol
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  depends_on            = [module.rds, module.access_manager, module.network_module]
}
```

# Dependencies

This module relies on the network, rds, and access_manager modules to source essential configuration elements such as instance profile, subnet IDs, Security Group IDs, vpc id. These elements are crucial for setting up required resources ensuring they are configured with the appropriate security group rules for secure communication with backend applications.
