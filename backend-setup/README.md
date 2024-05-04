# Terraform AWS Backend Configuration Module

## Module Overview

This module efficiently sets up an AWS S3 bucket for state file storage and a DynamoDB table to manage state locking. This ensures that modifications to the state are carried out sequentially, preventing concurrent updates by multiple users or systems.

In a typical DevOps environment, managing AWS resources via Terraform requires a mechanism to allow only one team member to apply changes at any given time, thus avoiding configuration conflicts.

To address this, our implementation leverages a DynamoDB table for robust state locking. Every Terraform operation first checks for an existing lock within DynamoDB and proceeds only if the lock is available. This setup ensures reliable, conflict-free updates in dynamic, collaborative settings.

### Why DynamoDB for State Locking?

DynamoDB is an excellent choice for managing Terraform state locks due to its:
- **High availability**: Ensures that the locking mechanism is always operational.
- **Scalability**: Easily handles growing infrastructure needs without performance degradation.
- **Low-latency operations**: Provides fast access to locks, minimizing delays in Terraform operations.
- **Fine-grained access control**: Prevents unauthorized simultaneous state modifications.
- **Seamless AWS integration**: Works efficiently with other AWS services, making it ideal for AWS-centric infrastructures.

## Resources

### `aws_s3_bucket`
- **Purpose**: Creates an S3 bucket to store Terraform state files securely with Server-side encryption with Amazon S3 managed keys (SSE-S3)


### `aws_s3_bucket_versioning`
- **Purpose**: Manages versioning of the S3 bucket. Deleting this resource will either suspend versioning or remove it from the Terraform state if the bucket is unversioned.

### `aws_dynamodb_table`
- **Purpose**: Establishes a DynamoDB table used to manage the state locking mechanism.

## Usage

To implement this locking mechanism, execute the following commands within **backend-setup module** to set up an encrypted S3 bucket and a DynamoDB table:


```bash
terraform init
terraform plan
terraform apply
```

After these resources are successfully provisioned, you must configure the backend.tf file at the root directory with the S3 bucket name and DynamoDB table name. This configuration is critical to enable the Terraform state locking mechanism.

## Important Limitations on Backend Configuration:
Only one backend configuration is allowed per configuration file.
Backend blocks cannot reference named values, such as input variables, locals, or data source attributes.
Values within backend blocks cannot be referenced elsewhere in your Terraform configuration. For additional details, refer to the Terraform documentation on resource attribute references.