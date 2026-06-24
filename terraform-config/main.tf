
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = var.sa_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document     = "index.html"
    error_404_document = "custom_not_found.html"
  }
}

resource "azurerm_storage_blob" "index" {
  for_each               = local.files
  name                   = each.key
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "D://projects//Cloud-Resume-Challenge//frontend//${each.key}"
  content_type           = each.value
  depends_on = [
    azurerm_storage_account.storage
  ]

}

module "azure_cosmos_db" {
  source              = "Azure/cosmosdb/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cosmos_account_name = var.cosmosdb_account_name
  cosmos_api          = "table"
  tables              = var.tables
  public_network_access_enabled = true
  ip_firewall_enabled           = false 
  depends_on = [
    azurerm_resource_group.rg
  ]
}

