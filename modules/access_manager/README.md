# Terraform AWS Access Manager  Module

## Module Overview

This Terraform module is designed to configure AWS resources effectively. It provisions an IAM Role for EC2 instances, facilitates access to an RDS KMS Key for encryption and decryption, integrates AWS Managed Policy for seamless management of EC2 instances, and allows logging permissions to interact with log streams.


## Data Sources

### `aws_caller_identity`
- **Purpose**: Retrieves the account ID associated with the current Terraform AWS provider credentials, ensuring operations are performed under the correct AWS account.

## Resources

### `aws_iam_role`
- **Purpose**: Establishes an IAM Role for EC2 instances to enable assumed role access and permissions.

### `aws_iam_policy`
- **Purpose**: Defines a policy attached to the EC2 IAM Role, outlining specific permissions for actions on designated resources.

### `aws_iam_policy_attachment`
- **Purpose**: Attaches a managed IAM policy to the specified IAM role, enhancing role capabilities with pre-defined policies.

### `aws_iam_instance_profile`
- **Purpose**: Creates an IAM instance profile that can be used by EC2 instances for role assumption and access management.

### `aws_kms_key_policy`
- **Purpose**: Modifies the policy of an RDS KMS Key to authorize the EC2 IAM Role for operations such as encrypting and decrypting data.


## Usage

This module is used within a Terraform configuration by referencing it with a `module` block. The configuration depends on the `rds` module for RDS-related resources like the KMS Key and Secrets Manager ARN.

```hcl
module "access_manager" {
  source                 = "../../modules/access_manager"
  rds_kms_key_id         = module.rds.rds_kms_arn
  rds_secret_manager_arn = module.rds.rds_secret_manager_arn
  depends_on             = [module.rds]
}
```


## Dependencies

RDS Module: This module depends on the rds module for obtaining the necessary KMS Key ID, which is essential for configuring the IAM policies that permit encryption and decryption activities. It also updates the RDS KMS Key policy to allow read and write access by the EC2 IAM Role.