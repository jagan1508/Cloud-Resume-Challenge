
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}

}


resource "azurerm_storage_account" "storage" {
  name                     = var.sa_name
  resource_group_name      = var.rg_name
  location                 = var.location
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
  source                 = "${path.module}/../frontend/${each.key}"
  content_type           = each.value
  depends_on = [
    azurerm_storage_account.storage
  ]

}


resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmosdb_account_name
  location            = var.location
  resource_group_name = var.rg_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  public_network_access_enabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableTable"
  }

}

resource "azurerm_cosmosdb_table" "table" {
  for_each            = var.tables
  name                = each.value.table_name
  resource_group_name = var.rg_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = 400

  depends_on = [
    azurerm_cosmosdb_account.cosmos
  ]
}

resource "azurerm_service_plan" "svcplan" {
  name                = "counter-app-service-plan-arc"
  resource_group_name = var.rg_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}
resource "azurerm_linux_function_app" "funapp" {
  name                = "counter-functionapparc"
  resource_group_name = var.rg_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  service_plan_id            = azurerm_service_plan.svcplan.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
    cors {
      allowed_origins = ["*"]
    }
  }
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "ENABLE_ORYX_BUILD"              = "true"
    "AzureWebJobsStorage"            = azurerm_storage_account.storage.primary_connection_string
    "CONNECTION_STRING"              = "DefaultEndpointsProtocol=https;AccountName=${azurerm_cosmosdb_account.cosmos.name};AccountKey=${azurerm_cosmosdb_account.cosmos.primary_key};TableEndpoint=https://${azurerm_cosmosdb_account.cosmos.name}.table.cosmos.azure.com:443/;"
  }
}
