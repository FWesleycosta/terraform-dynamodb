################################################################################
# DynamoDB Table Outputs
################################################################################

output "table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "ID da tabela DynamoDB (mesmo que o nome da tabela)"
  value       = aws_dynamodb_table.this.id
}

output "table_name" {
  description = "Nome da tabela DynamoDB"
  value       = aws_dynamodb_table.this.name
}

output "table_hash_key" {
  description = "Hash key (partition key) da tabela"
  value       = aws_dynamodb_table.this.hash_key
}

output "table_billing_mode" {
  description = "Modo de cobrança da tabela"
  value       = aws_dynamodb_table.this.billing_mode
}

output "table_stream_arn" {
  description = "ARN do DynamoDB Stream (se habilitado)"
  value       = aws_dynamodb_table.this.stream_arn
}

output "table_stream_label" {
  description = "Timestamp do stream, no formato ISO 8601 (se habilitado)"
  value       = aws_dynamodb_table.this.stream_label
}
