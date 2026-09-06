############################################
# Remote state - Lab 3 (eastus2 network, the region this lab protects)
# and Lab 7 (eastus2 host pool and workspace - the SHARED workspace
# this lab's application group attaches to; DR does not get its own
# workspace, unlike Lab 14's active-active design)
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

data "terraform_remote_state" "lab07_avd_core" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.primary_state_resource_group
    storage_account_name = var.primary_state_storage_account
    container_name       = "tfstate"
    key                  = "avd-lab-core.tfstate"
  }
}

# CORRECTED: added so westus2 can peer to centralus and reach its
# domain controller, not just eastus2's. See peering-centralus.tf.
data "terraform_remote_state" "lab11_network" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.primary_state_resource_group
    storage_account_name = var.primary_state_storage_account
    container_name       = "tfstate"
    key                  = "avd-lab-multiregion-network.tfstate"
  }
}

data "terraform_remote_state" "lab12_identity" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.primary_state_resource_group
    storage_account_name = var.primary_state_storage_account
    container_name       = "tfstate"
    key                  = "avd-lab-regional-identity.tfstate"
  }
}
