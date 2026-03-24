# ============================================
# PostgreSQL Flexible Servers (3 instances)
# ============================================

# 1. PostgreSQL for auth-service
resource "azurerm_postgresql_flexible_server" "auth" {
  count                         = var.deploy_databases ? 1 : 0
  name                          = "pg-auth-${local.prefix}"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.postgres_location
  version                       = "15"
  zone                          = "3"
  administrator_login           = var.postgres_admin_user
  administrator_password        = var.postgres_admin_password
  sku_name                      = var.postgres_sku
  storage_mb                    = 32768
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true
  tags                          = local.tags
}

resource "azurerm_postgresql_flexible_server_database" "auth_db" {
  count     = var.deploy_databases ? 1 : 0
  name      = "auth_db"
  server_id = azurerm_postgresql_flexible_server.auth[0].id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "auth_allow_azure" {
  count            = var.deploy_databases ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.auth[0].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# 2. PostgreSQL for flag-service
resource "azurerm_postgresql_flexible_server" "flags" {
  count                         = var.deploy_databases ? 1 : 0
  name                          = "pg-flags-${local.prefix}"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.postgres_location
  version                       = "15"
  zone                          = "1"
  administrator_login           = var.postgres_admin_user
  administrator_password        = var.postgres_admin_password
  sku_name                      = var.postgres_sku
  storage_mb                    = 32768
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true
  tags                          = local.tags
}

resource "azurerm_postgresql_flexible_server_database" "flags_db" {
  count     = var.deploy_databases ? 1 : 0
  name      = "flags_db"
  server_id = azurerm_postgresql_flexible_server.flags[0].id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "flags_allow_azure" {
  count            = var.deploy_databases ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.flags[0].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# 3. PostgreSQL for targeting-service
resource "azurerm_postgresql_flexible_server" "targeting" {
  count                         = var.deploy_databases ? 1 : 0
  name                          = "pg-targeting-${local.prefix}"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.postgres_location
  version                       = "15"
  zone                          = "1"
  administrator_login           = var.postgres_admin_user
  administrator_password        = var.postgres_admin_password
  sku_name                      = var.postgres_sku
  storage_mb                    = 32768
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true
  tags                          = local.tags
}

resource "azurerm_postgresql_flexible_server_database" "targeting_db" {
  count     = var.deploy_databases ? 1 : 0
  name      = "targeting_db"
  server_id = azurerm_postgresql_flexible_server.targeting[0].id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "targeting_allow_azure" {
  count            = var.deploy_databases ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.targeting[0].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
