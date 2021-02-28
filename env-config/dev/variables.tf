variable "region" {
  description = "AWS region to bootstrap infrastructure"
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment to bootstrap"
  default = ""
}