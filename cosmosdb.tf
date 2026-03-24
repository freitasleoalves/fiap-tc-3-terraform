# ============================================
# Azure Cosmos DB - Table API (replaces AWS DynamoDB)
# ============================================

resource "azurerm_cosmosdb_account" "main" {
  count               = var.deploy_databases ? 1 : 0
  name                = "cosmos-${local.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  tags                = local.tags

  capabilities {
    name = "EnableTable"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_table" "evaluation_events" {
  count               = var.deploy_databases ? 1 : 0
  name                = "EvaluationEvents"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main[0].name

  throughput = 400
}
