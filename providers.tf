terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "rg-production-storage-bsouth"
    storage_account_name = "sttfstatebsouth"
    container_name       = "fiap"
    key                  = "togglemaster.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 4.15"
    }
    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = "~> 3.34"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

# Alertas Inteligentes (APM) + Service Map: ver datadog.tf
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

# Gerenciamento de Incidentes (PagerDuty): ver pagerduty.tf
provider "pagerduty" {
  token = var.pagerduty_token
}
