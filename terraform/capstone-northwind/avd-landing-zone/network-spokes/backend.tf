terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-avdlz-01"
    storage_account_name = "sttfstatenwavdlz01"
    container_name       = "tfstate"
    key                  = "avdlz-network-spokes.tfstate"
  }
}
