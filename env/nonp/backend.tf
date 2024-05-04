terraform {
  backend "s3" {
    bucket         = "setu-tf-state-bucket"
    key            = "nonp/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
