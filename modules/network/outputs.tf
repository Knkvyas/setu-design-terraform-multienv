output "vpc_id" {
  value = aws_vpc.main.id
}
output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "app_subnet_ids" {
  value       = aws_subnet.app_subnet.*.id
  description = "List of IDs of application subnets"
}

output "db_subnet_ids" {
  value       = aws_subnet.db_subnet.*.id
  description = "List of IDs of database subnets"
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
}

output "app_subnet_azs" {
  value       = aws_subnet.app_subnet.*.availability_zone
  description = "List of Availability Zones for application subnets"
}

output "db_subnet_azs" {
  value       = aws_subnet.db_subnet.*.availability_zone
  description = "List of Availability Zones for database subnets"
}

output "public_subnet_azs" {
  value = aws_subnet.public_subnet.*.availability_zone
}

output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "public_app_security_group_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.public_app_sg.id
}

output "public_app_security_group_arn" {
  description = "The ARN of the application security group"
  value       = aws_security_group.public_app_sg.arn
}

output "private_app_security_group_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.private_app_sg.id
}

output "private_app_security_group_arn" {
  description = "The ARN of the application security group"
  value       = aws_security_group.private_app_sg.arn
}
output "rds_security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}

output "rds_security_group_arn" {
  description = "The ARN of the RDS security group"
  value       = aws_security_group.rds_sg.arn
}
