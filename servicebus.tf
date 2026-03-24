# ============================================
# Azure Service Bus (replaces AWS SQS)
# ============================================

resource "azurerm_servicebus_namespace" "main" {
  count               = var.deploy_databases ? 1 : 0
  name                = "sb-${local.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.servicebus_sku
  tags                = local.tags
}

resource "azurerm_servicebus_queue" "evaluation_events" {
  count        = var.deploy_databases ? 1 : 0
  name         = "evaluation-events"
  namespace_id = azurerm_servicebus_namespace.main[0].id

  max_delivery_count    = 10
  lock_duration         = "PT30S"
  max_size_in_megabytes = 1024
}
