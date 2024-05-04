output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_lock_table.id
}

output "statefile_s3_name" {
  value = aws_s3_bucket.tf_s3_state.id
}