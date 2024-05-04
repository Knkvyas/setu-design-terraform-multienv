resource "aws_s3_bucket" "tf_s3_state" {
    
    bucket = var.backend_s3_name

    lifecycle {
        prevent_destroy = true
    }
    
    tags = {
        Name = "Terraform State Bucket"
        Environment = var.env
    }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.tf_s3_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# AWS DynamoDB table definition for state locking

resource "aws_dynamodb_table" "terraform_lock_table" {
  name           = var.backend_db_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  deletion_protection_enabled = true

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.env} Terraform State Lock Table"
    Environment = var.env
  }
}