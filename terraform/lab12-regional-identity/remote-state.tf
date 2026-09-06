############################################
# Remote state - Lab 11's centralus network
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
