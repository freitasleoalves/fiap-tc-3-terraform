# ============================================
# Azure Cache for Redis (evaluation-service)
# ============================================

resource "azurerm_redis_cache" "main" {
  count                         = var.deploy_databases ? 1 : 0
  name                          = "redis-${local.prefix}"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  capacity                      = var.redis_capacity
  family                        = var.redis_family
  sku_name                      = var.redis_sku
  non_ssl_port_enabled          = true
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
  tags                          = local.tags

  redis_configuration {
  }
}
