################################################################################
# Example: Complete DynamoDB Table
################################################################################

module "dynamodb" {
  source = "../../modules/aws_dynamodb_table"

  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  attribute_name = var.attribute_name
  attribute_type = var.attribute_type

  tags = {
    Name        = var.table_name
    Environment = "test"
    ManagedBy   = "Terratest"
  }
}
