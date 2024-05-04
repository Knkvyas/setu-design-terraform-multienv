variable "region" {
  type = string
  default = "us-east-1"
}

variable "env" {
  type = string
  default = "dev"
}

variable "availability_zones" {
  description = "List of availability zones in which to create subnets"
  type        = list(string)
}

variable "db_identifier" {
  type = string
}
variable "db_instance_class" {
  type = string
}
variable "db_engine" {
  type = string
}
variable "db_engine_version" {
  type = string
}

variable "db_storage" {
  default = 20
}
variable "db_storage_type" {
  type = string
}

variable "db_username" {
  type = string
}

variable "backup_retention_period" {
  default = 7
}

variable "subnet_ids" {
  type = list(string)
  description = "Subnet IDs for the RDS cluster"
}

variable "security_group_id" {
  type = string
  description = "Security Group ID for the RDS cluster"
}

