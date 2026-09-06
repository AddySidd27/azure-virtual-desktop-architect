############################################
# Remote state - Lab 11 (centralus resource groups), Lab 7 (eastus2 host
# pool), Lab 14 (centralus host pool)
############################################

data "terraform_remote_state" "lab11_network" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.primary_state_resource_group
    storage_account_name = var.primary_state_storage_account
    container_name       = "tfstate"
    key                  = "avd-lab-multiregion-network.tfstate"
  }
}

data "terraform_remote_state" "lab07_avd_core" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.primary_state_resource_group
    storage_account_name = var.primary_state_storage_account
    container_name       = "tfstate"
    key                  = "avd-lab-core.tfstate"
  }
}

data "terraform_remote_state" "lab14_hostpools" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.primary_state_resource_group
    storage_account_name = var.primary_state_storage_account
    container_name       = "tfstate"
    key                  = "avd-lab-active-active-hostpools.tfstate"
  }
}

data "azurerm_resource_group" "eastus2_service" {
  name = "rg-avd-service-lab-eus2-01"
}
