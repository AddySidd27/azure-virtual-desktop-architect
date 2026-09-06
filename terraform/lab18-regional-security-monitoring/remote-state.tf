############################################
# Remote state - Lab 11 (centralus monitoring/network RGs), Lab 14 (host pool)
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

data "terraform_remote_state" "lab14_hostpools" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.primary_state_resource_group
    storage_account_name = var.primary_state_storage_account
    container_name       = "tfstate"
    key                  = "avd-lab-active-active-hostpools.tfstate"
  }
}
