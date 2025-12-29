variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "terraform_workspace" {
  description = "The Terraform workspace name"
  type        = string
  default     = "dev"
}