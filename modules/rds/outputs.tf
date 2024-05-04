output "db_instance_endpoint" {
  value       = aws_db_instance.rds.endpoint
  description = "The endpoint of the RDS instance"
}

output "db_instance_port" {
  value       = aws_db_instance.rds.port
  description = "The port of the RDS instance"
}

output "rds_kms_arn" {
  value = aws_kms_key.rds_kms_key.arn
}

output "rds_secret_manager_arn" {
  value = aws_secretsmanager_secret.rds_password.arn
}