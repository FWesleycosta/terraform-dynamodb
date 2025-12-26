resource "aws_dynamodb_table" "this" {

  name         = var.name
  hash_key     = var.hash_key
  billing_mode = var.billing_mode

  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  attribute {
    name = var.attribute_name
    type = var.attribute_type
  }

  tags = var.tags
}




