############################################
# Remote state - Lab 7 (eastus2 application group) and Lab 14 (centralus)
############################################

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
