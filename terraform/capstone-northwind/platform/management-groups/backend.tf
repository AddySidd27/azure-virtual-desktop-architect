terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-platform-01"
    storage_account_name = "sttfstatenwplat01"
    container_name       = "tfstate"
    key                  = "platform-management-groups.tfstate"
  }
}
