variable "backend_ami_id" {
  type        = string
  description = "The AMI ID for the backend instances"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "The instance type for the EC2 instances"
}

variable "app_iam_profile" {
  type        = string
  description = "The IAM Role Profile arn"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ASG and ALB"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for the EC2 instances and ALB"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the resources will be deployed"
}

variable "nlb_name" {
  type = string
}

variable "nlb_tg_port" {
  type        = number
  description = "ALB Target Group Port"
  default = 80
}

variable "nlb_tg_protocol" {
  type        = string
  description = "ALB Target Group Protocol"
  default = "TCP"
}

variable "nlb_listener_port" {
  type        = number
  description = "ALB Target Group Port"
  default = 80
}

variable "nlb_listener_protocol" {
  type        = string
  description = "ALB Target Group Protocol"
  default = "TCP"
}

variable "min_size" {
  type = number
  default = 0
}

variable "max_size" {
  type = number
  default = 3
}

variable "desired_capacity" {
  type = number
  default = 1
}