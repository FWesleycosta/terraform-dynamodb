################################################################################
# Terraform Configuration
################################################################################

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "path/to/my/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "my-terraform-lock-table"
  }
}
