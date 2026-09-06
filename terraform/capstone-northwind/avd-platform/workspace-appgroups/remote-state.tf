data "terraform_remote_state" "avdplt_host_pools" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.avdplt_state_resource_group
    storage_account_name = var.avdplt_state_storage_account
    container_name       = "tfstate"
    key                  = var.host_pools_state_key
  }
}

data "terraform_remote_state" "avdlz_network_spokes" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.avdlz_state_resource_group
    storage_account_name = var.avdlz_state_storage_account
    container_name       = "tfstate"
    key                  = "avdlz-network-spokes.tfstate"
  }
}

locals {
  host_pool_ids      = data.terraform_remote_state.avdplt_host_pools.outputs.host_pool_ids
  avd_resource_group = var.location == "eastus2" ? data.terraform_remote_state.avdlz_network_spokes.outputs.eastus2_avd_resource_group : data.terraform_remote_state.avdlz_network_spokes.outputs.westeurope_avd_resource_group
}
