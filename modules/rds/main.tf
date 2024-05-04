resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS Key for encrypting RDS instances"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name = "RDS KMS Key"
  }
}

resource "aws_kms_alias" "rds_kms_name" {
  name = "alias/${var.env}_rds_kms"
  target_key_id = aws_kms_key.rds_kms_key.key_id
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB Subnet Group"
  }
}

resource "random_password" "master"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "rds_password" {
  name = "rds-password"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.master.result
}

resource "aws_db_instance" "rds" {
  identifier                = var.db_identifier
  instance_class            = var.db_instance_class
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  allocated_storage         = var.db_storage
  storage_type              = var.db_storage_type
  multi_az                  = true
  username                  = var.db_username
  password         = random_password.master.result
  skip_final_snapshot       = false
  final_snapshot_identifier = "rds-final-snapshot" 
  delete_automated_backups  = false
  deletion_protection = true
  backup_retention_period   = var.backup_retention_period
  backup_window   = "03:00-05:00"
  maintenance_window = "Sun:06:00-Sun:07:00"
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.name
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.rds_kms_key.arn


  tags = {
    Name = "${var.env} environment HA MySQL Database"
  }
}