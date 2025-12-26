################################################################################
# Example Outputs
################################################################################

output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = module.dynamodb.table_arn
}

output "dynamodb_table_id" {
  description = "ID da tabela DynamoDB"
  value       = module.dynamodb.table_id
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_hash_key" {
  description = "Hash key da tabela"
  value       = module.dynamodb.table_hash_key
}

output "dynamodb_table_billing_mode" {
  description = "Billing mode da tabela"
  value       = module.dynamodb.table_billing_mode
}
