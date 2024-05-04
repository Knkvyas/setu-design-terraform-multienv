# Terraform Module for Deploying Private Backend Applications Behind NLB

## Module Overview

This Terraform module is designed to deploy a private backend application in AWS, utilizing a Network Load Balancer (NLB) for traffic management. It sets up the necessary infrastructure, including EC2 instances within an Auto Scaling Group (ASG), configured with the latest Amazon Linux 2 AMI, and managed through a custom launch template.

## Resources

### Data Source: `aws_ami`
- **Purpose**: Automatically selects the most recent Amazon Linux 2 AMI based on specified criteria, ensuring the EC2 instances run on updated and secure software.
- **Filters**:
  - AMI name pattern: `amzn2-ami-hvm-*-x86_64-ebs`
  - Owner: Amazon

### Resource: `aws_launch_template`
- **Purpose**: Defines the configuration for launching EC2 instances as part of the Auto Scaling Group, tailored for backend application requirements.
- **Configuration**:
  - Optionally uses a predefined AMI ID or defaults to the latest Amazon Linux 2 AMI.
  - Specifies instance type and associated security groups.

### Resource: `aws_autoscaling_group`
- **Purpose**: Manages the lifecycle and scaling of EC2 instances, ensuring consistent application availability and performance.
- **Features**:
  - Dynamically scales between minimum and maximum capacity limits.
  - Registers instances with a target group associated with the NLB.

### Resource: `aws_lb`
- **Purpose**: Provisions a Network Load Balancer configured to handle internal traffic, optimizing and distributing backend application loads.
- **Characteristics**:
  - Set as internal (not exposed to the public internet).
  - Tied to specified subnets for deployment.

### Resource: `aws_lb_target_group`
- **Purpose**: Directs traffic from the NLB to the associated EC2 instances, with detailed health checks to ensure traffic is only sent to healthy instances.
- **Health Check Settings**:
  - Checks are performed using the specified protocol and port.
  - Configured thresholds and intervals manage instance health validation.

### Resource: `aws_lb_listener`
- **Purpose**: Listens on a specific port and protocol, managing how traffic is forwarded to the target group from the NLB.
- **Action**:
  - Forwards incoming requests to the designated target group.

## Usage

Here is how you can use this module in your Terraform configuration:

```hcl
module "private_backend_app" {
  source                = "../../modules/private_backend"
  nlb_name              = "private-backend-nlb"
  backend_ami_id        = var.private_app_ami
  instance_type         = var.instance_type
  app_iam_profile       = module.access_manager.iam_instance_profile
  security_group_ids    = [module.network_module.private_app_security_group_id]
  vpc_id                = module.network_module.vpc_id
  subnet_ids            = module.network_module.app_subnet_ids
  nlb_listener_port     = var.nlb_listener_port
  nlb_listener_protocol = var.nlb_listener_protocol
  nlb_tg_port           = var.nlb_tg_port
  nlb_tg_protocol       = var.nlb_tg_protocol
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  depends_on            = [module.rds, module.access_manager, module.network_module]
}
```

# Dependencies

This module relies on the network, rds, and access_manager modules to source essential configuration elements such as instance profile, subnet IDs, Security Group IDs, vpc id. These elements are crucial for setting up required resources ensuring they are configured with the appropriate security group rules for secure communication with backend applications.