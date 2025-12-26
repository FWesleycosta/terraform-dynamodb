################################################################################
# Example Variables
################################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode da tabela"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Hash key da tabela"
  type        = string
}

variable "attribute_name" {
  description = "Nome do atributo"
  type        = string
}

variable "attribute_type" {
  description = "Tipo do atributo"
  type        = string
  default     = "S"
}

variable "read_capacity" {
  description = "Read capacity (apenas para PROVISIONED)"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Write capacity (apenas para PROVISIONED)"
  type        = number
  default     = null
}
