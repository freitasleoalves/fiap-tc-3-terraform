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
