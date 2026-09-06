terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-lab-eus2-01"
    storage_account_name = "REPLACE_WITH_YOUR_STORAGE_ACCOUNT"
    container_name       = "tfstate"
    key                  = "avd-lab-operations.tfstate"
  }
}
