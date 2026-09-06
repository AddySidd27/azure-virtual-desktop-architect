############################################
# Remote state - cross-layer reads, per Part G section 2.
# Replaces the manual tfvars copy-paste this module originally used.
############################################

data "terraform_remote_state" "avdlz_network_spokes" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.avdlz_state_resource_group
    storage_account_name = var.avdlz_state_storage_account
    container_name       = "tfstate"
    key                  = "avdlz-network-spokes.tfstate"
  }
}

data "terraform_remote_state" "platform_identity" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.platform_state_resource_group
    storage_account_name = var.platform_state_storage_account
    container_name       = "tfstate"
    key                  = "platform-identity.tfstate"
  }
}

data "terraform_remote_state" "platform_monitoring" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.platform_state_resource_group
    storage_account_name = var.platform_state_storage_account
    container_name       = "tfstate"
    key                  = "platform-monitoring.tfstate"
  }
}
