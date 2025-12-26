# Terraform DynamoDB Module

Módulo Terraform reutilizável para criar tabelas DynamoDB na AWS, otimizado para uso como backend de state locking do Terraform.

## Funcionalidades

- Suporte a **PAY_PER_REQUEST** (On-Demand) e **PROVISIONED** billing modes
- Validações de input integradas
- Tags configuráveis
- Outputs completos para integração com outros módulos

## Requisitos

| Nome | Versão |
|------|--------|
| terraform | >= 1.0.0 |
| aws | ~> 5.0 |

## Uso

### Exemplo básico (State Locking)

```hcl
module "dynamodb" {
  source = "./modules/aws_dynamodb_table"

  name           = "terraform-state-locking"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute_name = "LockID"
  attribute_type = "S"

  tags = {
    Environment = "production"
    Project     = "infrastructure"
  }
}
```

### Exemplo com capacidade provisionada

```hcl
module "dynamodb" {
  source = "./modules/aws_dynamodb_table"

  name           = "minha-tabela"
  billing_mode   = "PROVISIONED"
  hash_key       = "id"
  read_capacity  = 5
  write_capacity = 5
  attribute_name = "id"
  attribute_type = "S"

  tags = {
    Environment = "development"
  }
}
```

## Inputs

| Nome | Descrição | Tipo | Default | Obrigatório |
|------|-----------|------|---------|:-----------:|
| name | Nome da tabela DynamoDB | `string` | - | sim |
| billing_mode | Modo de cobrança (PROVISIONED ou PAY_PER_REQUEST) | `string` | `"PAY_PER_REQUEST"` | não |
| hash_key | Nome do atributo usado como partition key | `string` | - | sim |
| read_capacity | Capacidade de leitura (apenas para PROVISIONED) | `number` | `null` | não |
| write_capacity | Capacidade de escrita (apenas para PROVISIONED) | `number` | `null` | não |
| attribute_name | Nome do atributo para a chave primária | `string` | - | sim |
| attribute_type | Tipo do atributo (S, N, B) | `string` | `"S"` | não |
| tags | Tags para aplicar à tabela | `map(string)` | `{}` | não |

## Outputs

| Nome | Descrição |
|------|-----------|
| table_arn | ARN da tabela DynamoDB |
| table_id | ID da tabela DynamoDB |
| table_name | Nome da tabela DynamoDB |
| table_hash_key | Hash key (partition key) da tabela |
| table_billing_mode | Modo de cobrança da tabela |
| table_stream_arn | ARN do DynamoDB Stream (se habilitado) |
| table_stream_label | Timestamp do stream (se habilitado) |

## Estrutura do Projeto

```
terraform-dynamodb/
├── backend.tf              # Configuração do Terraform e providers
├── provider.tf             # Configuração do provider AWS
├── variables.tf            # Variáveis do módulo raiz
├── main.tf                 # Chamada do módulo DynamoDB
├── output.tf               # Outputs do módulo raiz
├── modules/
│   └── aws_dynamodb_table/
│       ├── main.tf         # Recurso DynamoDB
│       ├── variables.tf    # Variáveis do módulo
│       └── output.tf       # Outputs do módulo
├── examples/
│   └── complete/           # Exemplo completo para testes
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── providers.tf
└── test/
    ├── go.mod              # Dependências Go
    ├── go.sum              # Checksums das dependências
    └── dynamodb_test.go    # Testes com Terratest
```

## Testes

Os testes são escritos em Go usando [Terratest](https://terratest.gruntwork.io/).

### Pré-requisitos

- Go 1.21+
- Credenciais AWS configuradas
- Terraform instalado

### Executar testes

```bash
cd test
go mod download
go test -v -timeout 30m
```

### O que os testes validam

| Teste | Descrição |
|-------|-----------|
| `TestDynamoDBModule` | Cria tabela com PAY_PER_REQUEST e valida outputs |
| `TestDynamoDBModuleProvisioned` | Cria tabela com capacidade provisionada e valida configurações |

## Configuração do Backend S3 (Opcional)

Para usar esta tabela como lock para state remoto, configure o backend no seu projeto:

```hcl
terraform {
  backend "s3" {
    bucket         = "seu-bucket-terraform-state"
    key            = "path/to/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locking"
  }
}
```

## Comandos Úteis

```bash
# Inicializar
terraform init

# Validar configuração
terraform validate

# Planejar mudanças
terraform plan

# Aplicar mudanças
terraform apply

# Destruir recursos
terraform destroy
```

## Validações

O módulo inclui validações para:

| Campo | Regra |
|-------|-------|
| name | 3 a 255 caracteres |
| billing_mode | PROVISIONED ou PAY_PER_REQUEST |
| read_capacity / write_capacity | 1 a 40000 |
| attribute_type | S (String), N (Number) ou B (Binary) |

## Licença

MIT
