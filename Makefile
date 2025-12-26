################################################################################
# Makefile - Terraform DynamoDB Module
# Compatível com Windows, Linux e macOS
################################################################################

# Detecta o Sistema Operacional
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    SHELL := cmd.exe
    RM := del /Q /F
    RMDIR := rmdir /S /Q
    MKDIR := mkdir
    SEP := \\
    EXE := .exe
    NULL := NUL
else
    DETECTED_OS := $(shell uname -s)
    RM := rm -f
    RMDIR := rm -rf
    MKDIR := mkdir -p
    SEP := /
    EXE :=
    NULL := /dev/null
endif

# Variáveis
TERRAFORM := terraform$(EXE)
GO := go$(EXE)
AWS_REGION ?= us-east-1

# Diretórios
ROOT_DIR := $(shell pwd)
TEST_DIR := test
EXAMPLES_DIR := examples/complete
MODULES_DIR := modules/aws_dynamodb_table

# Cores para output (não funciona no Windows cmd)
ifneq ($(DETECTED_OS),Windows)
    GREEN := \033[0;32m
    YELLOW := \033[0;33m
    RED := \033[0;31m
    NC := \033[0m
endif

.PHONY: help init validate plan apply destroy clean test test-clean fmt lint check-tools install-tools

##@ Geral

help: ## Mostra esta ajuda
	@echo "Terraform DynamoDB Module - Makefile"
	@echo ""
	@echo "Sistema detectado: $(DETECTED_OS)"
	@echo ""
	@echo "Comandos disponíveis:"
	@echo ""
ifeq ($(DETECTED_OS),Windows)
	@findstr /R "^[a-zA-Z_-]*:.*##" $(MAKEFILE_LIST) | findstr /V "PHONY"
else
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
endif

##@ Verificação de Ferramentas

check-tools: ## Verifica se as ferramentas necessárias estão instaladas
	@echo "Verificando ferramentas..."
ifeq ($(DETECTED_OS),Windows)
	@where terraform >$(NULL) 2>&1 || (echo "ERRO: Terraform nao encontrado" && exit 1)
	@where go >$(NULL) 2>&1 || (echo "ERRO: Go nao encontrado" && exit 1)
	@where aws >$(NULL) 2>&1 || (echo "AVISO: AWS CLI nao encontrado")
else
	@which terraform > $(NULL) 2>&1 || (echo "$(RED)ERRO: Terraform não encontrado$(NC)" && exit 1)
	@which go > $(NULL) 2>&1 || (echo "$(RED)ERRO: Go não encontrado$(NC)" && exit 1)
	@which aws > $(NULL) 2>&1 || echo "$(YELLOW)AVISO: AWS CLI não encontrado$(NC)"
endif
	@echo "Terraform: OK"
	@echo "Go: OK"
	@$(TERRAFORM) version
	@$(GO) version

install-tools: ## Mostra instruções para instalar ferramentas
	@echo "=== Instruções de Instalação ==="
	@echo ""
	@echo "Sistema detectado: $(DETECTED_OS)"
	@echo ""
ifeq ($(DETECTED_OS),Windows)
	@echo "=== Windows ==="
	@echo ""
	@echo "1. Terraform:"
	@echo "   winget install HashiCorp.Terraform"
	@echo "   ou: choco install terraform"
	@echo ""
	@echo "2. Go:"
	@echo "   winget install GoLang.Go"
	@echo "   ou: choco install golang"
	@echo ""
	@echo "3. AWS CLI:"
	@echo "   winget install Amazon.AWSCLI"
	@echo "   ou: choco install awscli"
	@echo ""
	@echo "4. Make (para usar este Makefile):"
	@echo "   choco install make"
	@echo "   ou use WSL/Git Bash"
else ifeq ($(DETECTED_OS),Darwin)
	@echo "=== macOS ==="
	@echo ""
	@echo "1. Homebrew (se não tiver):"
	@echo "   /bin/bash -c \"\$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
	@echo ""
	@echo "2. Terraform:"
	@echo "   brew tap hashicorp/tap"
	@echo "   brew install hashicorp/tap/terraform"
	@echo ""
	@echo "3. Go:"
	@echo "   brew install go"
	@echo ""
	@echo "4. AWS CLI:"
	@echo "   brew install awscli"
else
	@echo "=== Linux ==="
	@echo ""
	@echo "1. Terraform:"
	@echo "   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg"
	@echo "   echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \$$(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list"
	@echo "   sudo apt update && sudo apt install terraform"
	@echo ""
	@echo "2. Go:"
	@echo "   sudo apt install golang-go"
	@echo "   ou: snap install go --classic"
	@echo ""
	@echo "3. AWS CLI:"
	@echo "   sudo apt install awscli"
	@echo "   ou: pip install awscli"
endif

##@ Terraform - Módulo Raiz

init: check-tools ## Inicializa o Terraform
	@echo "Inicializando Terraform..."
	@$(TERRAFORM) init

validate: init ## Valida a configuração do Terraform
	@echo "Validando configuração..."
	@$(TERRAFORM) validate

fmt: ## Formata os arquivos Terraform
	@echo "Formatando arquivos..."
	@$(TERRAFORM) fmt -recursive

fmt-check: ## Verifica formatação sem alterar
	@$(TERRAFORM) fmt -recursive -check

plan: validate ## Gera plano de execução
	@echo "Gerando plano..."
	@$(TERRAFORM) plan -out=tfplan

apply: ## Aplica as mudanças (requer plan)
	@echo "Aplicando mudanças..."
	@$(TERRAFORM) apply tfplan

apply-auto: validate ## Aplica mudanças automaticamente (sem confirmação)
	@echo "Aplicando mudanças (auto-approve)..."
	@$(TERRAFORM) apply -auto-approve

destroy: ## Destrói todos os recursos
	@echo "Destruindo recursos..."
	@$(TERRAFORM) destroy

destroy-auto: ## Destrói recursos automaticamente (sem confirmação)
	@echo "Destruindo recursos (auto-approve)..."
	@$(TERRAFORM) destroy -auto-approve

##@ Terraform - Exemplo

init-example: check-tools ## Inicializa o exemplo
	@echo "Inicializando exemplo..."
	@cd $(EXAMPLES_DIR) && $(TERRAFORM) init

validate-example: init-example ## Valida o exemplo
	@echo "Validando exemplo..."
	@cd $(EXAMPLES_DIR) && $(TERRAFORM) validate

plan-example: validate-example ## Gera plano do exemplo
	@echo "Gerando plano do exemplo..."
	@cd $(EXAMPLES_DIR) && $(TERRAFORM) plan

##@ Testes

test: check-tools ## Executa todos os testes
	@echo "Executando testes..."
	@cd $(TEST_DIR) && $(GO) mod download && $(GO) test -v -timeout 30m

test-short: check-tools ## Executa testes rápidos (sem criar recursos AWS)
	@echo "Executando testes curtos..."
	@cd $(TEST_DIR) && $(GO) mod download && $(GO) test -v -short

test-clean: ## Limpa cache de testes Go
	@echo "Limpando cache de testes..."
	@cd $(TEST_DIR) && $(GO) clean -testcache

##@ Limpeza

clean: ## Limpa arquivos temporários do Terraform
	@echo "Limpando arquivos temporários..."
ifeq ($(DETECTED_OS),Windows)
	@if exist .terraform $(RMDIR) .terraform
	@if exist tfplan $(RM) tfplan
	@if exist .terraform.lock.hcl $(RM) .terraform.lock.hcl
	@if exist $(EXAMPLES_DIR)\.terraform $(RMDIR) $(EXAMPLES_DIR)\.terraform
	@if exist $(EXAMPLES_DIR)\tfplan $(RM) $(EXAMPLES_DIR)\tfplan
	@if exist $(EXAMPLES_DIR)\.terraform.lock.hcl $(RM) $(EXAMPLES_DIR)\.terraform.lock.hcl
else
	@$(RMDIR) .terraform 2>$(NULL) || true
	@$(RM) tfplan 2>$(NULL) || true
	@$(RM) .terraform.lock.hcl 2>$(NULL) || true
	@$(RMDIR) $(EXAMPLES_DIR)/.terraform 2>$(NULL) || true
	@$(RM) $(EXAMPLES_DIR)/tfplan 2>$(NULL) || true
	@$(RM) $(EXAMPLES_DIR)/.terraform.lock.hcl 2>$(NULL) || true
endif
	@echo "Limpeza concluída!"

clean-all: clean test-clean ## Limpa tudo (Terraform + testes)
	@echo "Limpeza completa concluída!"

##@ CI/CD

ci: fmt-check validate test-short ## Pipeline CI (formatação, validação, testes curtos)
	@echo "Pipeline CI concluído!"

lint: fmt-check validate ## Executa linting (formato + validação)
	@echo "Linting concluído!"
