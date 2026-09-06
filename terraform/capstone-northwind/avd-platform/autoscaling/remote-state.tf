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
  # Only the three POOLED persona host pools get a scaling plan.
  # Personal pools (cad, dev) use Start VM on Connect instead (already
  # set on the host pool in Part F) - Power Management Autoscale's
  # ramp-up/ramp-down schedule model doesn't apply to per-user
  # assigned personal desktops the same way, matching Lab 17's own
  # scope exactly.
  pooled_host_pool_ids = {
    for k, v in data.terraform_remote_state.avdplt_host_pools.outputs.host_pool_ids : k => v
    if contains(["task", "know", "fin"], k)
  }

  avd_resource_group = var.location == "eastus2" ? data.terraform_remote_state.avdlz_network_spokes.outputs.eastus2_avd_resource_group : data.terraform_remote_state.avdlz_network_spokes.outputs.westeurope_avd_resource_group

  schedule = var.location == "eastus2" ? var.eastus2_schedule : var.westeurope_schedule
}
