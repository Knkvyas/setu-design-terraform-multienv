variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "List of availability zones in which to create subnets"
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
}


variable "inbound_ports" {
  description = "List of inbound ports for which NACL & Security group rules will be created"
  type        = list(string)
}


variable "rds_egress_from_port" {
  description = "Starting port for engress"
  type        = number
}

variable "rds_egress_to_port" {
  description = "Ending port for engress"
  type        = number
}

