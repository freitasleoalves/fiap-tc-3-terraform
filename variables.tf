# ============================================
# General
# ============================================

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "postgres_location" {
  description = "Azure region for PostgreSQL (may differ from main location due to availability)"
  type        = string
  default     = "eastus2"
}

variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "togglemaster"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "deploy_databases" {
  description = "Deploy database and messaging resources (PostgreSQL, Redis, Service Bus, Cosmos DB)"
  type        = bool
  default     = false
}

# ============================================
# AKS
# ============================================

variable "aks_node_count" {
  description = "Initial node count for AKS"
  type        = number
  default     = 2
}

variable "aks_min_count" {
  description = "Minimum node count for AKS autoscaling"
  type        = number
  default     = 2
}

variable "aks_max_count" {
  description = "Maximum node count for AKS autoscaling"
  type        = number
  default     = 4
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

# ============================================
# PostgreSQL
# ============================================

variable "postgres_admin_user" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "pgadmin"
}

variable "postgres_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "postgres_sku" {
  description = "PostgreSQL SKU (tier_family_cores)"
  type        = string
  default     = "B_Standard_B1ms"
}

# ============================================
# Redis
# ============================================

variable "redis_sku" {
  description = "Redis SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

variable "redis_family" {
  description = "Redis family (C for Basic/Standard, P for Premium)"
  type        = string
  default     = "C"
}

variable "redis_capacity" {
  description = "Redis cache capacity (0-6)"
  type        = number
  default     = 0
}

# ============================================
# Service Bus
# ============================================

variable "servicebus_sku" {
  description = "Service Bus SKU"
  type        = string
  default     = "Basic"
}

# ============================================
# ArgoCD
# ============================================

variable "argocd_github_token" {
  description = "GitHub PAT for ArgoCD repository access"
  type        = string
  sensitive   = true
}

# ============================================
# Auth
# ============================================

variable "master_key" {
  description = "Master key for auth-service admin endpoints"
  type        = string
  sensitive   = true
  default     = "master-key-prod-2026"
}

# ============================================
# Observabilidade (Fase 4) - Datadog / PagerDuty / Discord / Self-Healing
# ============================================

variable "monitored_services" {
  description = "Microsserviços cobertos pelos alertas inteligentes (Datadog Monitor), PagerDuty e self-healing"
  type        = list(string)
  default     = ["evaluation-service", "auth-service"]
}

variable "datadog_api_key" {
  description = "Datadog API Key (Organization Settings > API Keys)"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog Application Key (Organization Settings > Application Keys), necessária para o provider gerenciar monitors/webhooks/integrações"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Site do Datadog (datadoghq.com, datadoghq.eu, us5.datadoghq.com, etc.)"
  type        = string
  default     = "datadoghq.com"
}

variable "pagerduty_token" {
  description = "PagerDuty API Token (User Settings > API Access Keys), com permissão de leitura e escrita"
  type        = string
  sensitive   = true
}

variable "pagerduty_user_email" {
  description = "E-mail do usuário PagerDuty (dono da conta) que receberá os incidentes na escalation policy"
  type        = string
}

variable "discord_webhook_url" {
  description = "URL do Webhook do canal Discord usado para as notificações de incidente (ChatOps). Ex: https://discord.com/api/webhooks/<id>/<token>"
  type        = string
  sensitive   = true
}

variable "github_selfheal_token" {
  description = "GitHub PAT (escopo 'repo') usado pelo Datadog para disparar o repository_dispatch de self-healing no repositório GitOps"
  type        = string
  sensitive   = true
}

variable "gitops_repo" {
  description = "Repositório GitOps (owner/repo) onde roda o workflow de self-healing (.github/workflows/self-heal.yml)"
  type        = string
  default     = "freitasleoalves/fiap-tc-3-gitops"
}
