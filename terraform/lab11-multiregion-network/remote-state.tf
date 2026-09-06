############################################
# Remote state - Lab 3's eastus2 network
#
# Lab 11 peers the new centralus VNet against the existing eastus2 VNet
# built in Lab 3. This reads Lab 3's state to get that VNet's resource ID
# and resource group name without hard-coding them.
############################################

data "terraform_remote_state" "lab03_network" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.primary_state_resource_group
    storage_account_name = var.primary_state_storage_account
    container_name       = "tfstate"
    key                  = "avd-lab-network.tfstate"
  }
}
