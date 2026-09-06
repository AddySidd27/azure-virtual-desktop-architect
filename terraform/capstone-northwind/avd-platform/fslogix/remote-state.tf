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
  avd_resource_group  = var.location == "eastus2" ? data.terraform_remote_state.avdlz_network_spokes.outputs.eastus2_avd_resource_group : data.terraform_remote_state.avdlz_network_spokes.outputs.westeurope_avd_resource_group
  avd_hosts_subnet_id = var.location == "eastus2" ? data.terraform_remote_state.avdlz_network_spokes.outputs.eastus2_avd_hosts_subnet_id : data.terraform_remote_state.avdlz_network_spokes.outputs.westeurope_avd_hosts_subnet_id
}
