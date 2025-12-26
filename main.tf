#################################################################
#    DYNAMODB TABLE

# This module creates a DynamoDB table for Terraform state locking
##################################################################

module "dynamodb" {
  source = "./modules/aws_dynamodb_table"

  name           = "terraform-state-locking"
  read_capacity  = null
  write_capacity = null
  hash_key       = "LockID"
  billing_mode   = "PAY_PER_REQUEST"
  attribute_name = "LockID"
  attribute_type = "S"

  tags = {
    Name         = "terraform-state-locking"
    Environment  = "production"
    Project      = "infrastructure"
    Date_Created = timestamp()
  }
}
