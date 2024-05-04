output "iam_instance_profile" {
  value = aws_iam_instance_profile.ec2_iam_profile.name
}

output "iam_role_arn" {
  value = aws_iam_role.ec2_rds_access_role.arn
}