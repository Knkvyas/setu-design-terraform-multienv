variable "region" {
  type = string
  default = "us-east-1"
}

variable "env" {
  type = string
  default = "dev"
}

variable "backend_s3_name" {
  type = string
}

variable "backend_db_name" {
  type = string
}

