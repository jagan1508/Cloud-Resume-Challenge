terraform {
  backend "azurerm" {
    resource_group_name  = "myTFResourceGroup"
    storage_account_name = "tfarcstorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

}