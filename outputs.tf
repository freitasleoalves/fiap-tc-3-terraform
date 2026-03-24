# ============================================
# AKS
# ============================================

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config_command" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

# ============================================
# ACR
# ============================================

output "acr_login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "ACR admin password"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

# ============================================
# PostgreSQL Connection Strings
# ============================================

output "postgres_auth_host" {
  description = "PostgreSQL host for auth-service"
  value       = var.deploy_databases ? azurerm_postgresql_flexible_server.auth[0].fqdn : null
}

output "postgres_auth_connection_string" {
  description = "PostgreSQL connection string for auth-service"
  value       = var.deploy_databases ? "postgres://${var.postgres_admin_user}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.auth[0].fqdn}:5432/auth_db?sslmode=require" : null
  sensitive   = true
}

output "postgres_flags_host" {
  description = "PostgreSQL host for flag-service"
  value       = var.deploy_databases ? azurerm_postgresql_flexible_server.flags[0].fqdn : null
}

output "postgres_flags_connection_string" {
  description = "PostgreSQL connection string for flag-service"
  value       = var.deploy_databases ? "postgres://${var.postgres_admin_user}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.flags[0].fqdn}:5432/flags_db?sslmode=require" : null
  sensitive   = true
}

output "postgres_targeting_host" {
  description = "PostgreSQL host for targeting-service"
  value       = var.deploy_databases ? azurerm_postgresql_flexible_server.targeting[0].fqdn : null
}

output "postgres_targeting_connection_string" {
  description = "PostgreSQL connection string for targeting-service"
  value       = var.deploy_databases ? "postgres://${var.postgres_admin_user}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.targeting[0].fqdn}:5432/targeting_db?sslmode=require" : null
  sensitive   = true
}

# ============================================
# Redis
# ============================================

output "redis_host" {
  description = "Redis hostname"
  value       = var.deploy_databases ? azurerm_redis_cache.main[0].hostname : null
}

output "redis_port" {
  description = "Redis non-SSL port"
  value       = var.deploy_databases ? azurerm_redis_cache.main[0].port : null
}

output "redis_connection_string" {
  description = "Redis connection string"
  value       = var.deploy_databases ? "redis://:${azurerm_redis_cache.main[0].primary_access_key}@${azurerm_redis_cache.main[0].hostname}:${azurerm_redis_cache.main[0].port}" : null
  sensitive   = true
}

output "redis_primary_key" {
  description = "Redis primary access key"
  value       = var.deploy_databases ? azurerm_redis_cache.main[0].primary_access_key : null
  sensitive   = true
}

# ============================================
# Service Bus (SQS equivalent)
# ============================================

output "servicebus_namespace" {
  description = "Service Bus namespace"
  value       = var.deploy_databases ? azurerm_servicebus_namespace.main[0].name : null
}

output "servicebus_connection_string" {
  description = "Service Bus connection string"
  value       = var.deploy_databases ? azurerm_servicebus_namespace.main[0].default_primary_connection_string : null
  sensitive   = true
}

output "servicebus_queue_name" {
  description = "Service Bus queue name"
  value       = var.deploy_databases ? azurerm_servicebus_queue.evaluation_events[0].name : null
}

# ============================================
# Cosmos DB (DynamoDB equivalent)
# ============================================

output "cosmosdb_account_name" {
  description = "Cosmos DB account name"
  value       = var.deploy_databases ? azurerm_cosmosdb_account.main[0].name : null
}

output "cosmosdb_connection_string" {
  description = "Cosmos DB Table API connection string"
  value       = var.deploy_databases ? "DefaultEndpointsProtocol=https;AccountName=${azurerm_cosmosdb_account.main[0].name};AccountKey=${azurerm_cosmosdb_account.main[0].primary_key};TableEndpoint=https://${azurerm_cosmosdb_account.main[0].name}.table.cosmos.azure.com:443/;" : null
  sensitive   = true
}

output "cosmosdb_table_name" {
  description = "Cosmos DB table name"
  value       = var.deploy_databases ? azurerm_cosmosdb_table.evaluation_events[0].name : null
}

# ============================================
# Resource Group
# ============================================

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

# ============================================
# ArgoCD
# ============================================

output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = helm_release.argocd.namespace
}

output "argocd_initial_admin_password_command" {
  description = "Command to get the ArgoCD initial admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
