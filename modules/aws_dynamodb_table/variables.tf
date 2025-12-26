################################################################################
# DynamoDB Table Variables
################################################################################

variable "name" {
  description = "Nome da tabela DynamoDB"
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 255
    error_message = "O nome da tabela deve ter entre 3 e 255 caracteres."
  }
}

variable "billing_mode" {
  description = "Modo de cobrança da tabela. Valores válidos: PROVISIONED ou PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "O billing_mode deve ser PROVISIONED ou PAY_PER_REQUEST."
  }
}

variable "hash_key" {
  description = "Nome do atributo que será usado como hash key (partition key)"
  type        = string
}

variable "read_capacity" {
  description = "Capacidade de leitura provisionada. Obrigatório quando billing_mode é PROVISIONED"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Capacidade de escrita provisionada. Obrigatório quando billing_mode é PROVISIONED"
  type        = number
  default     = null
}

################################################################################
# Attribute Variables
################################################################################

variable "attribute_name" {
  description = "Nome do atributo para a chave primária"
  type        = string
}

variable "attribute_type" {
  description = "Tipo do atributo. Valores válidos: S (String), N (Number), B (Binary)"
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.attribute_type)
    error_message = "O attribute_type deve ser S (String), N (Number) ou B (Binary)."
  }
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Mapa de tags para aplicar à tabela DynamoDB"
  type        = map(string)
  default     = {}
}
