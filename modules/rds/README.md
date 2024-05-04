# Terraform AWS RDS Configuration Module

## Module Overview

This Terraform module provisions a robust, encrypted Amazon RDS environment using AWS KMS for encryption, AWS Secrets Manager for sensitive data management, and a dedicated subnet group for database instances.

## Resources

### `aws_kms_key`
- **Purpose**: Creates an AWS KMS key for RDS instance encryption, ensuring data security.
- **Key Features**:
  - **Rotation**: Key rotation is enabled to enhance security.
  - **Deletion Window**: Configured with a 10-day deletion window to safeguard against premature deletions.

### `aws_kms_alias`
- **Purpose**: Establishes an alias for the KMS key, simplifying resource references across your configurations.
- **Configuration**:
  - Uses a dynamic environment-based naming convention.

### `aws_db_subnet_group`
- **Purpose**: Defines a DB subnet group to house RDS instances across specified subnets, enhancing database availability and performance across availability zones.
- **Subnets**: Utilizes user-defined subnet IDs for deployment.

### `random_password`
- **Purpose**: Generates a secure, random password for the RDS instance.
- **Complexity**:
  - Length: 16 characters
  - Includes special characters to meet security requirements.

### `aws_secretsmanager_secret`
- **Purpose**: Creates a secret in AWS Secrets Manager to securely store the RDS instance password.

### `aws_secretsmanager_secret_version`
- **Purpose**: Manages versions of the stored secret, ensuring the RDS instance password is up-to-date and secure.

### `aws_db_instance`
- **Purpose**: Provisions an RDS instance configured for high availability and security.
- **Features**:
  - Multi-AZ deployment for enhanced availability.
  - Encryption using the specified KMS key.
  - Comprehensive backup and maintenance settings.


## Usage

To use this module in your Terraform environment, you need to specify various configurations such as DB identifier, instance class, engine details, and connectivity settings. Here's a reference how to use this module:

```hcl
module "rds" {
  source                  = "../../modules/rds"
  env                     = var.env
  availability_zones      = var.availability_zones
  db_identifier           = var.db_identifier
  db_instance_class       = var.db_instance_class
  db_engine               = var.db_engine
  db_engine_version       = var.db_engine_version
  db_storage              = var.db_storage
  db_storage_type         = var.db_storage_type
  db_username             = var.db_username
  backup_retention_period = var.backup_retention_period
  subnet_ids              = module.network_module.db_subnet_ids
  security_group_id       = module.network_module.rds_security_group_id
  depends_on              = [module.network_module]
}

```


## Dependencies

This module relies on the network module to source essential configuration elements such as subnet IDs and Security Group IDs. These elements are crucial for setting up RDS instances within the designated subnets, ensuring they are configured with the appropriate security group rules for secure communication with backend applications.


