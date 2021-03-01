variable "region" {
  description = "AWS region to bootstrap infrastructure"
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment to bootstrap"
  default = ""
}

variable "key_pair" {
  description = "SSH Key pair to login to ec2 instances"
  default = ""
}

variable "bucket_name" {
  description = "S3 bucket for static content"
  default = ""
}